import SwiftUI
import Foundation

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [ExerciseItem] = []
    @Published var isLoading = false
    
    private let apiKey = "MtMQAv9uyv8Jyj0Zv9WmJQ==ep4ECY1pk5053BpD"
    private let baseURL = "https://api.api-ninjas.com/v1/exercises"
    
    func fetchExercises(for muscle: String) {
        guard let url = URL(string: "\(baseURL)?muscle=\(muscle)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        request.httpMethod = "GET"
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Erreur lors de la requête : \(error)")
                    return
                }
                
                guard let data = data else { return }
                do {
                    let decodedExercises = try JSONDecoder().decode([ExerciseItem].self, from: data)
                    self?.exercises = decodedExercises
                } catch {
                    print("Erreur de décodage : \(error)")
                }
            }
        }.resume()
    }
}

struct HomeView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var selectedExercise: ExerciseItem?
    @State private var selectedMuscle: String = "biceps" // Valeur par défaut
    let muscles = ["biceps", "triceps",  "chest","shoulders"]
    var email: String

    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    // Titre principal
                    Text("Push Yourself")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 16)

                    // Sélecteur de muscles
                    Picker("Select", selection: $selectedMuscle) {
                        ForEach(muscles, id: \.self) { muscle in
                            Text(muscle.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    // Bouton pour rechercher
                    Button("Search") {
                        viewModel.fetchExercises(for: selectedMuscle)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()

                    // Liste des exercices ou état de chargement
                    if viewModel.isLoading {
                        ProgressView("Chargement des exercices...")
                            .padding()
                    } else if viewModel.exercises.isEmpty {
                        Text("Aucun exercice disponible pour \(selectedMuscle).")
                            .padding()
                    } else {
                        List(viewModel.exercises, id: \.id) { exercise in
                            NavigationLink(
                                destination: ExerciseDetailView(exercise: exercise,email: email),
                                tag: exercise,
                                selection: $selectedExercise
                            ) {
                                ExerciseCard(exercise: exercise)
                            }
                        }
                        .navigationTitle("GoVibe")
                    }
                }
                .onAppear {
                    viewModel.fetchExercises(for: selectedMuscle) // Chargement initial
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            ChallengeView(email: email)
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Challenge")
                }

            ProfileView(email: email)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
        }
    }
}



struct ExerciseCard: View {
    let exercise: ExerciseItem
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell.fill") // Icône dynamique (à personnaliser)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(8)
                .background(Circle().fill(Color.green.opacity(0.3))) // Cercle coloré
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Muscle : \(exercise.muscle.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Difficulté : \(exercise.difficulty.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.white, .green.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
        )
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.vertical, 8)
    }
}


struct ExerciseItem: Identifiable, Decodable, Hashable {
    let id = UUID()
    let name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String
}
struct ExerciseDetailView: View {
    let exercise: ExerciseItem
    @State private var userId: String? = nil // UserId à récupérer depuis l'email
    var email: String
    @State private var timer: Timer?
    @State private var showTimer = false
    @State private var timeElapsed: Int = 10
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image placeholder en haut
                Image(systemName: "dumbbell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
                
                if showTimer {
                    Text(formatTime(timeElapsed))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .padding(.vertical, 16)
                        .frame(width: 200, height: 100) // Timer box size
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 3)
                        )
                        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
                }

                // Titre
                Text(exercise.name)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                // Muscle ciblé
                Text("Muscle selected : \(exercise.muscle.capitalized)")
                    .font(.headline)
                    .foregroundColor(.secondary)

                // Informations supplémentaires
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                        Text("Type : \(exercise.type.capitalized)")
                    }
                    HStack {
                        Image(systemName: "wrench.fill")
                        Text("Equipement : \(exercise.equipment.capitalized)")
                    }
                    HStack {
                        Image(systemName: "star.fill")
                        Text("difficulty level : \(exercise.difficulty.capitalized)")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()
                    .padding(.vertical)

                // Instructions
                Text("Instructions :")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(exercise.instructions)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                    .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)

                Button(action: {
                    print("Start button clicked")  // Débogage pour vérifier que le bouton déclenche bien l'action
                    startTimer()
                    fetchUserByEmail(email: email) { userId in
                        if let userId = userId {
                            self.userId = userId
                            // Démarrer le chrono dès le début
                            sendExerciseDataToBackend(userId: userId)  // Envoi des données à la base
                        } else {
                            print("Erreur: Impossible de récupérer l'ID utilisateur.")
                        }
                    }
                }) {
                    Text("Start")
                    
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.5), radius: 5)
                        .scaleEffect(1.1)
                    
                
                }
                .padding(.top, 16)

                // Bouton pour mettre en pause ou relancer
            
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground)) // Fond clair
    }

    private func startTimer() {
        showTimer = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async { // Assurez-vous que l'update est fait sur le thread principal
                if timeElapsed > 0 {
                    timeElapsed -= 1
                } else {
                    // Lorsque le chrono se termine, afficher l'alerte et jouer le son
                    showAlert = true
                    timer?.invalidate()
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func sendExerciseDataToBackend(userId: String) {
        // URL de l'API backend
        guard let url = URL(string: "https://a92e-197-3-6-252.ngrok-free.app/exercices") else {
            print("URL invalide.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Créer les données JSON pour la requête
        let payload: [String: Any] = [
            "name": exercise.name,
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

    func fetchUserByEmail(email: String, completion: @escaping (String?) -> Void) {
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
