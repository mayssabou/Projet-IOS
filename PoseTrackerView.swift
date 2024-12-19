import SwiftUI
import WebKit
import AVFoundation

// ViewModel pour gérer les données reçues de JavaScript
class ViewModel: ObservableObject {
    @Published var info: String = "Waiting for data..."
       @Published var currentCount: Int = 0 // Compteur de répétitions
       @Published var message: String = ""
       @Published var timerValue: Int = 30 // Compteur de secondes
       @Published var showCongratulations: Bool = false // Afficher le message de félicitations
       @Published var timerActive: Bool = false // Si le timer est actif
       @Published var reloadTrigger: Bool = false // Déclencher le rechargement
       @Published var showAlert: Bool = false // Pour afficher l'alerte
       @Published var alertMessage: String = "" // Message de l'alerte
       let maxCount = 10 // Objectif de répétitions
 var userId: String?
    func updateData(with data: String) {
        DispatchQueue.main.async {
            self.info = data
        }
    }
    func restartExercise() {
        self.currentCount = 0
        self.timerValue = 30
        self.showCongratulations = false
        self.timerActive = false
        self.showAlert = false
    }

    func startTimer() {
           self.timerActive = true
           self.timerValue = 30
           Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
               if self.timerValue > 0 && self.currentCount < self.maxCount {
                   self.timerValue -= 1
               } else {
                   timer.invalidate()
                   self.timerActive = false
                   
                   // Vérifier si l'objectif a été atteint
                   if self.currentCount >= self.maxCount {
                       self.showCongratulations = true
                       self.alertMessage = "🎉 Congratulations! You have reached the goal of  \(self.maxCount) repetitions in \(30 - self.timerValue) seconds. Great job! 🎉"
                   } else {
                       self.alertMessage = "Time's up! Try again to reach \(self.maxCount) repetitions."
                   }
                   self.showAlert = true
                   self.submitParticipation()
               }
           }
       }
 // Fonction pour soumettre la participation de l'utilisateur
 func submitParticipation() {
     guard let userId = self.userId else { return }
    
     // Exemple de requête pour envoyer les données au backend
     let url = URL(string: "https://a92e-197-3-6-252.ngrok-free.app/challenge-participations")!
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
     let body: [String: Any] = [
         "userId": userId,
         "repetitions": currentCount,
         "exercise": "squat", // Exemples, vous pouvez changer cela dynamiquement
         "duration": 30 - self.timerValue // Temps restant
     ]
    
     do {
         let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
         request.httpBody = jsonData
     } catch {
         print("Erreur de sérialisation des données : \(error)")
         return
     }
    
     let task = URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
             print("Erreur lors de l'envoi de la participation : \(error)")
             return
         }
         // Gestion de la réponse, si nécessaire
         print("Participation envoyée avec succès.")
     }
     task.resume()
 }

 // Fonction pour récupérer l'ID utilisateur par email
 func fetchUserIdByEmail(email: String, completion: @escaping (String?) -> Void) {
     guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
         completion(nil)
         return
     }

     guard let url = URL(string: "https://a92e-197-3-6-252.ngrok-free.app/user/\(encodedEmail)") else {
         completion(nil)
         return
     }

     var request = URLRequest(url: url)
     request.httpMethod = "GET"
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")

     let task = URLSession.shared.dataTask(with: request) { data, response, error in
         guard let data = data, error == nil else {
             completion(nil)
             return
         }

         do {
             if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let userId = json["_id"] as? String {
                 completion(userId)
             } else {
                 completion(nil)
             }
         } catch {
             completion(nil)
         }
     }
     task.resume()
 }
}




// WebView intégrée à SwiftUI
struct WebView: UIViewRepresentable {
    var url: URL
    @ObservedObject var viewModel: ViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        // Autorisation pour la caméra
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "iosListener")
        webConfiguration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)

        // Script JavaScript pour gérer la permission de la caméra
        let cameraPermissionScript = """
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            navigator.mediaDevices.getUserMedia({ video: true })
            .then(function(stream) {
                console.log('Camera access granted');
                window.webkit.messageHandlers.iosListener.postMessage('Camera access granted');
            })
            .catch(function(error) {
                console.log('Camera access denied');
                window.webkit.messageHandlers.iosListener.postMessage('Camera access denied');
            });
        }
        """
        let script = WKUserScript(source: cameraPermissionScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webConfiguration.userContentController.addUserScript(script)
        
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        var viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let data = message.body as? String {
                // Envoyer les données à la vue
                self.viewModel.updateData(with: data)
                
                // Logique similaire à Android pour gérer les répétitions et autres
                if data.contains("counter") {
                    // Exemple de mise à jour du compteur à partir des données JS
                    self.viewModel.currentCount += 1
                    if self.viewModel.currentCount == 1 && !self.viewModel.timerActive {
                        self.viewModel.startTimer()
                    }
                }
            }
        }
    }
}

// Vue principale de l'application
struct PoseTrackerView: View {
    @StateObject var viewModel = ViewModel()
    @State private var selectedExercise = "squat"
    @State private var selectedDifficulty = "easy"
    @State private var showWebView = false
    @State private var token = "4de8d13e-362c-47ba-b16b-5fc519e71d27"
    var email: String

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if showWebView {
                        WebView(
                            url: constructURL(
                                token: token,
                                exercise: selectedExercise,
                                difficulty: selectedDifficulty
                            ),
                            viewModel: viewModel
                        )
                        .frame(width: 350, height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.blue.opacity(0.5), radius: 10)
                        .padding()
                        
                        VStack(spacing: 20) {
                            Text("Repetitions : \(viewModel.currentCount) / \(viewModel.maxCount)")
                                .font(.headline)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.5), radius: 5)
                            
                            Text("Time Remaining : \(viewModel.timerValue) seconds")
                                .font(.headline)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.5), radius: 5)
                           /* if !viewModel.timerActive {
                                Button(action: {
                                    viewModel.restartExercise()
                                }) {
                                    Text("Restart")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(12)
                                        .shadow(color: Color.red.opacity(0.5), radius: 5)
                                }
                            }
                            */
                        }
                    } else {
                        VStack(spacing: 30) {
                            Text("Select your exercise and difficulty")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.blue)
                                .multilineTextAlignment(.center)
                            
                            Picker("Exercise", selection: $selectedExercise) {
                                Text("Squat").tag("squat")
                                Text("Push-up").tag("pushup")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(12)
                            
                            Picker("Difficulty", selection: $selectedDifficulty) {
                                Text("Easy").tag("easy")
                                Text("Medium").tag("medium")
                                Text("Hard").tag("hard")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(12)
                            
                            Button(action: {
                                showWebView = true
                            }) {
                                Text("Start Challenge")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                    .shadow(color: Color.blue.opacity(0.5), radius: 5)
                                    .scaleEffect(1.1)
                                    .animation(.easeInOut, value: showWebView)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.currentCount >= viewModel.maxCount ? "Congratulations !" : "Time's up"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {  viewModel.fetchUserIdByEmail(email: email) { userId in viewModel.userId = userId }
            
        }
    }

    private func constructURL(token: String, exercise: String, difficulty: String) -> URL {
 
        let baseUrl = "https://app.posetracker.com/pose_tracker/tracking"
 
        var components = URLComponents(string: baseUrl)!
        components.queryItems = [
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "exercise", value: exercise),
            URLQueryItem(name: "difficulty", value: difficulty),
            URLQueryItem(name: "width", value: "350"),
            URLQueryItem(name: "height", value: "350"),
            URLQueryItem(name: "progression", value: "true")
        ]
        return components.url!
    }
}
