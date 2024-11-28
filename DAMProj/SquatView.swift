import SwiftUI
import AVKit
import AVFoundation

struct SquatView: View {
    @State private var showTimer = false
    @State private var timeElapsed: Int = 0
    @State private var player: AVPlayer?
    @State private var timer: Timer?
    @State private var showAlert = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = true // État pour contrôler la lecture de la vidéo
    @State private var userId: String? = nil // UserId à récupérer depuis l'email
    var email: String // L'email de l'utilisateur, qui sera utilisé comme userId
    let videoURL = Bundle.main.url(forResource: "Squat", withExtension: "mp4")
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
                Text("Squat")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#2C3E50"))
                    .padding(.bottom, 8)

                // Description
                Text("""
                Squats are a highly effective exercise for building strength, improving mobility, and enhancing lower body fitness.

                                    - Strengthens the legs and glutes.
                                    - Improves core stability.
                                    - Boosts overall flexibility and mobility
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

            }
            .padding()
            .navigationBarTitle("Squat", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Bravo!"),
                    message: Text("Congratulations on completing the exercise!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadPlayer() // Charger la vidéo uniquement si nécessaire
            }  /*.onAppear {
                startTimer() // Charger la vidéo uniquement si nécessaire
            }*/
        }
    }

    private func startTimer() {
        // Vérifier si le timer est déjà en cours, et si oui, on ne le recrée pas
        if let timer = self.timer {
            print("Timer already exists")
            timer.invalidate()  // Invalider si déjà en cours
        }

        // Réinitialisation des variables
        showTimer = true
        timeElapsed = 0

        // Créer un nouveau timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            print("Timer fired!")  // Débogage pour vérifier si le timer se déclenche

            DispatchQueue.main.async {
                self.timeElapsed += 1
                print("Current timeElapsed: \(self.timeElapsed)")  // Afficher chaque incrémentation

                if self.timeElapsed >= 10 {
                    print("Timer reached 10 seconds. Stopping...")  // Afficher lorsque le timer atteint 10
                    self.showAlert = true
                    self.playCongratulationsSound()
                    self.timer?.invalidate()  // Arrêter le timer
                }
            }
        }

        print("Timer started")  // Vérification que la fonction est bien appelée
    }

    private func loadPlayer() {
        // Ne relance la vidéo que si elle n'est pas déjà en cours de lecture
        if player == nil, let videoURL = videoURL {
            player = AVPlayer(url: videoURL)
            player?.play()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func playCongratulationsSound() {
        guard let soundURL = congratulationsSound else { return }
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
            "name": "squat",
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

