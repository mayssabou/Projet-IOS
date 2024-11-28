//
//  ProfileView.swift
//  DAMProj
//
//  Created by Apple Esprit on 6/11/2024.
//

import SwiftUI
struct ProfileView: View {
    @State private var isUserDeleted = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Your Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.purple)
                    .padding(.top, 40)
                
                // Contenu de la vue avec des boutons dans une VStack
                VStack(spacing: 16) {
                    // Edit Profile Button
                    NavigationLink(destination: editProfileView()) {
                        Text("Edit Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.3)))
                            .shadow(radius: 5)
                    }

                    // Reset Password Button
                    NavigationLink(destination: ForgetPasswordView().toolbar(.visible)) {
                        Text("Reset Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.3)))
                            .shadow(radius: 5)
                    }
                    
                    // Delete Profile Button
                    Button(action: deleteProfile) {
                        Text("Delete Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple.opacity(0.3)))
                            .shadow(radius: 5)
                    }
                    .padding(.top, 20)
                    .navigationDestination(isPresented: $isUserDeleted, destination: { SignUpView() })
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.horizontal)
        }
    }
    
    // Fonction pour supprimer le profil
    func deleteProfile() {
        // Implémentation de la suppression du profil (remplace cette ligne par ta logique réelle)
        isUserDeleted = true
        let id = "67255598f3f3847a306346fe" // Id de l'utilisateur à supprimer
        guard let url = URL(string: "https://37de-197-3-6-252.ngrok-free.app/user/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
}

struct editProfileView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Titre de la vue
                Text("Edit Your Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.purple)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    // First Name
                    inputField(label: "First Name", text: $firstName)
                    
                    // Last Name
                    inputField(label: "Last Name", text: $lastName)
                    
                    // Email
                    inputField(label: "Email", text: $email)
                }
                .padding(.horizontal)
                
                // Update Profile Button
                Button(action: updateProfile) {
                    Text("Update Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .padding(.horizontal)
        }
    }
    
    // Fonction de champ de saisie personnalisé
    private func inputField(label: String, text: Binding<String>) -> some View {
        
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
                .foregroundColor(.pink)
            TextField("Enter your \(label.lowercased())", text: text)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1)))
                .shadow(radius: 5)
                .padding(.bottom, 12)
        }
    }
    
    // Fonction de mise à jour du profil
    func updateProfile() {
        let id = "user_id_here"
        guard let url = URL(string: "https://c652-197-3-6-252.ngrok-free.app/user/\(id)") else { return }
        let body = [
            "nom": lastName,
            "prenom": firstName,
            "email": email,
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        } catch {
            print("Error updating profile")
        }
    }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            editProfileView()
            ProfileView()
        }
    }
}
