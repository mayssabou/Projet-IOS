
import SwiftUI

// Modèle pour les participants
struct Participant: Identifiable, Codable {
    let id: String
    let user: User
    let participatedAt: String
    let repetitions: Int
    
    // Utilisation des clés JSON spécifiques
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user
        case participatedAt
        case repetitions
    }
}

// Modèle pour l'utilisateur
struct User: Codable {
    let nom: String
    let prenom: String
    let email: String
}


struct ChallengeView: View {
    @State private var participants: [Participant] = []
    @State private var isChallengeStarted = false
    @State private var user: User? = nil  // Pour stocker l'utilisateur récupéré
    var email: String  // Accepte l'email en paramètre

    var body: some View {
        NavigationStack {
                   VStack(spacing: 20) {
                       if email.isEmpty {
                           Text("Error: No email passed.")
                               .font(.title)
                               .foregroundColor(.red)
                               .padding()
                       } else {
                           VStack(alignment: .leading, spacing: 10) {
                               if let user = user {
                                   Text("Welcome, \(user.nom) \(user.prenom)")
                                       .font(.system(size: 28, weight: .bold, design: .rounded))
                                       .foregroundColor(.blue)
                               } else {
                                   Text("Loading user info...")
                                       .font(.title)
                                       .foregroundColor(.gray)
                               }
                              
                               Text("Join the challenge!")
                                   .font(.title2)
                                   .foregroundColor(.green)
                                   .padding(.top, 5)
                           }
                           .padding()
                           .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.green.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                           .cornerRadius(15)

                           Image("challenge")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 300, height: 200)
                               .padding(.top, 20)

                           // Liste des participants avec une vue de carte élégante
                           Text("Leaderboard")
                                   .font(.title2)
                                   .fontWeight(.bold)
                                   .foregroundColor(.blue)
                                   .padding(.top, 20)

                               List(participants) { participant in
                                   VStack(alignment: .leading, spacing: 10) {
                                       HStack {
                                           Text("\(participant.user.nom) \(participant.user.prenom)")
                                               .font(.headline)
                                               .foregroundColor(.blue)
                                               .padding(.leading, 15)
                                           Spacer()
                                           Text("Score: \(participant.repetitions)")
                                               .font(.subheadline)
                                               .fontWeight(.bold)
                                               .foregroundColor(.green)
                                               .padding(.trailing, 15)
                                       }
                                      
                           
                                   }
                                   .padding()
                                   .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
                                   .cornerRadius(15)
                                   .shadow(radius: 5)
                                   .padding(.vertical, 5)
                               }
                               .listStyle(PlainListStyle())
                           Spacer()

                           Button(action: {
                               startChallenge()
                           }) {
                               Text("Start Challenge")
                                   .font(.system(size: 18, weight: .semibold, design: .rounded))
                                   .foregroundColor(.white)
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                                   .cornerRadius(12)
                                   .shadow(radius: 5)
                           }
                           .padding(.top, 20)
                           .navigationDestination(isPresented: $isChallengeStarted) {
                               PoseTrackerView(email: email)
                           }
                       }
                   }
                   .padding()
                   .background(Color.white.edgesIgnoringSafeArea(.all))
                   .cornerRadius(25)
                   .shadow(radius: 5)
                   .padding(.horizontal)
               }
               .onAppear {
                   fetchUserByEmail(email: email) { fetchedUser in
                       if let fetchedUser = fetchedUser {
                           DispatchQueue.main.async {
                               self.user = fetchedUser
                           }
                       }
                   }
                   fetchParticipants()
               }
    }

    // Fonction pour démarrer le challenge
    func startChallenge() {
        // Logique de démarrage du challenge
        isChallengeStarted = true
    }

    // Fonction pour récupérer les participants
    func fetchParticipants() {
        guard let url = URL(string: "https://9c1e-197-3-6-252.ngrok-free.app/challenge-participations") else {
            print("URL invalide")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur de réseau: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Données manquantes")
                return
            }

            // Affichage des données brutes pour vérification
            print("Données reçues: \(String(data: data, encoding: .utf8) ?? "Aucune donnée")")

            do {
                // Décodage des participants
                var decodedParticipants = try JSONDecoder().decode([Participant].self, from: data)

                // Tri des participants par répétitions (du plus grand au plus petit)
                decodedParticipants.sort { $0.repetitions > $1.repetitions }

                DispatchQueue.main.async {
                    self.participants = decodedParticipants
                    print("Participants décodés et triés: \(decodedParticipants)")  // Affichage des participants décodés et triés
                }
            } catch {
                print("Erreur de décodage: \(error)")
            }
        }.resume()
    }

    // Fonction pour récupérer l'utilisateur par email
    func fetchUserByEmail(email: String, completion: @escaping (User?) -> Void) {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }

        guard let url = URL(string: "https://9c1e-197-3-6-252.ngrok-free.app/user/\(encodedEmail)") else {
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
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(user)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}
