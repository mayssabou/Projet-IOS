import SwiftUI
import WebKit

// ViewModel pour gérer les données reçues de JavaScript
class ViewModel: ObservableObject {
    @Published var info: String = "Waiting for data..."
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var navigateBack: Bool = false // Contrôler la navigation
    @Published var navigateToLogin: Bool = false // Contrôler la navigation vers login si nécessaire
    func updateData(with data: String) {
        DispatchQueue.main.async {
            self.info = data
        }
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
                
                // Vérification si l'exercice est mal effectué
                if data.contains("user is not in the detection frame") || data.contains("incorrect form") {
                    // Si l'exercice est mal effectué, afficher l'alerte
                    DispatchQueue.main.async {
                        self.viewModel.alertMessage = "The exercise is not performed correctly."
                        self.viewModel.showAlert = true
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
    
    @State private var isNavigatingToChallengeView = false // Contrôler la navigation
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
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
                    .edgesIgnoringSafeArea(.all)

                    Text(viewModel.info)
                        .padding()
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                } else {
                    VStack {
                        Text("Choose Your Exercise and Difficulty")
                                                  .font(.title)
                                                  .fontWeight(.bold)
                                                  .foregroundColor(.blue) // Change color to blue
                                                  .padding(.top, 40)
                                                  .multilineTextAlignment(.center)

                        Picker("Exercise", selection: $selectedExercise) {
                            Text("Squat").tag("squat")
                            Text("Push-up").tag("pushup")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                                                 .padding()
                                                 .background(Color.gray.opacity(0.1))
                                                 .cornerRadius(12)
                                                 .shadow(radius: 5)


                        Picker("Difficulty", selection: $selectedDifficulty) {
                            Text("Easy").tag("easy")
                            Text("Medium").tag("medium")
                            Text("Hard").tag("hard")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                                                    .padding()
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(12)
                                                    .shadow(radius: 5)

                        Button(action: {
                            showWebView = true
                        }) {
                            Text("Start the Challenge!")
                                                                .foregroundColor(.white)
                                                                .font(.headline)
                                                                .padding()
                                                                .background(Color.green)
                                                                .cornerRadius(12)
                                                                .shadow(radius: 10)
                                                                .scaleEffect(1.1)
                                                                .animation(.spring(), value: showWebView)
                        }
                    }
                }
                
                // NavigationLink conditionnel pour forcer la navigation vers ChallengeView
                NavigationLink(
                    destination: ChallengeView(), // Remplacez par votre vue ChallengeView
                    isActive: $isNavigatingToChallengeView
                ) {
                    EmptyView() // Aucun contenu visuel ici
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Warning !"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK")) {
                        // Lorsque l'alerte est fermée, naviguer vers ChallengeView
                        self.isNavigatingToChallengeView = true
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true) // Empêche le bouton de retour par défaut
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
