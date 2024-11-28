import SwiftUI
import AVKit
import AVFoundation

struct PushupView: View {
    @State private var showTimer = false
    @State private var timeElapsed: Int = 0
    @State private var player: AVPlayer?
    @State private var timer: Timer?
    @State private var showAlert = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = true // État pour contrôler la lecture de la vidéo
    @State private var userId: String? = nil // UserId à récupérer depuis l'email
    var email: String // L'email de l'utilisateur, qui sera utilisé comme userId
    let videoURL = Bundle.main.url(forResource: "Pushup", withExtension: "mp4")
    let congratulationsSound = Bundle.main.url(forResource: "Congratulations", withExtension: "mp3")

    var body: some View {
        NavigationView {
            VStack {
                // Chronomètre
                if showTimer {
                    Text(formatTime(timeElapsed))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .padding(.vertical, 16)
                }

                // Vidéo
                if let videoURL = videoURL {
                    VideoPlayer(player: player)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(16)
                        .padding(.bottom, 16)
                }

                // Titre
                Text("Pushup")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#2C3E50"))
                    .padding(.bottom, 8)

                // Description
                Text("""
                Push-ups are an excellent strength exercise that primarily targets the chest, shoulders, and triceps. They are perfect for:

                                  - Strengthening the upper body.
                                  - Improving core stability.
                                  - Increasing muscular endurance.
                """)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#ECF0F1")))
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
                // Bouton Démarrer l'essai
                Button(action: {
                    print("Start button clicked")  // Débogage pour vérifier que le bouton déclenche bien l'action
                    startTimer()
                    fetchUserByEmail(email: email) { userId in
                        if let userId = userId {
                            self.userId = userId
                              // Démarrer le chrono dès le début
                            loadPlayer()  // Lancer la vidéo après démarrage du chrono
                            sendExerciseDataToBackend(userId: userId)  // Envoi des données à la base
                        } else {
                            print("Erreur: Impossible de récupérer l'ID utilisateur.")
                        }
                    }
                }) {
                    Text("Start")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#2980B9"), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 16)

                // Bouton pour mettre en pause ou relancer
            }
            .padding()
            .navigationBarTitle("Pushup", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Bravo!"),
                    message: Text("Congratulations on completing the exercise!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadPlayer() // Démarre la vidéo dès que l'interface apparaît
            }
        }
    }

    private func startTimer() {
        showTimer = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeElapsed < 10 {
                timeElapsed += 1
            } else {
                // Lorsque le chrono se termine, afficher l'alerte et jouer le son
                showAlert = true
                playCongratulationsSound()
                timer?.invalidate()  // Arrêter le timer
            }
        }
    }

    private func loadPlayer() {
        // Ne relance la vidéo que si elle n'est pas déjà en cours de lecture
        if player == nil {
            guard let videoURL = videoURL else {
                return
            }
            player = AVPlayer(url: videoURL)
            player?.play()
        }
    }

    private func togglePlayback() {
        guard let player = player else { return }

        if isPlaying {
            player.pause() // Mettre en pause la vidéo
        } else {
            player.play() // Reprendre la vidéo
        }

        isPlaying.toggle() // Alterne entre lecture et pause
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func playCongratulationsSound() {
        guard let soundURL = congratulationsSound else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Erreur de lecture du son: \(error.localizedDescription)")
        }
    }
    
    
    
    func fetchUserByEmail(email: String, completion: @escaping (String?) -> Void) {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }

        guard let url = URL(string: "https://520d-197-21-87-58.ngrok-free.app/user/\(encodedEmail)") else {
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

    private func sendExerciseDataToBackend(userId: String) {
        // URL de l'API backend
        guard let url = URL(string: "https://520d-197-21-87-58.ngrok-free.app/exercices") else {
            print("URL invalide.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Créer les données JSON pour la requête
        let payload: [String: Any] = [
            "name": "pushup",
            "userId": userId,  // Utiliser l'ID utilisateur
        ]

        // Convertir les données en JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData

            // Envoyer la requête HTTP
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Vérification des erreurs
                if let error = error {
                    print("Erreur lors de l'envoi de la requête: \(error.localizedDescription)")
                    return
                }

                // Vérification du code de statut HTTP
                if let response = response as? HTTPURLResponse {
                    print("Code de statut HTTP: \(response.statusCode)")
                    
                    if response.statusCode == 200 {
                        print("Exercice ajouté avec succès.")
                    } else {
                        // Lire la réponse pour obtenir plus de détails
                        if let data = data, let body = String(data: data, encoding: .utf8) {
                            print("Réponse du serveur: \(body)")
                        } else {
                            print("Aucune réponse du serveur ou impossible de la lire.")
                        }
                        print("Échec de l'ajout de l'exercice.")
                    }
                }
            }
            task.resume()
        } catch {
            print("Erreur de sérialisation JSON: \(error.localizedDescription)")
        }
    }
}




