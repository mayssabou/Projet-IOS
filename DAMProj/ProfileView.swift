//
//  ProfileView.swift
//  DAMProj
//
//  Created by Apple Esprit on 6/11/2024.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    @State private var userEmail: String = ""
    @State private var userId: String? = nil
    @State private var isUserDeleted = false
    @State var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var navigateTologin = false
    var body: some View {
        NavigationStack {
            ZStack {
                // Fond avec une image (comme en Android)
                Image("profileb")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Contenu principal
                VStack(spacing: 10) {
                    // Flèche de retour (Navigation)
             
                    
                
                    
                    // Image de profil
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                        Image("user")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
                    }
                    .padding(.bottom, 16)

                    // Informations de l'utilisateur
                    Text("\(firstName) \(lastName)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.blue)
                    
                
                    
                    Spacer()
                    
                    // Boutons sous forme de "Rounded Rectangle"
                    VStack(spacing: 16) {
                        // Modifier le profil
                        NavigationLink(destination: editProfileView()) {
                            Text("Edit Profile")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        
                        // Réinitialiser le mot de passe
                        
                        
                        // Supprimer le profil
                        
                        
                        // Démarrer un challenge
                   
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                fetchUserDetails()
            }
        }
    }
    
    func fetchUserDetails() {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://520d-197-21-87-58.ngrok-free.app/user/\(encodedEmail)") else {
            print("URL incorrecte")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la récupération des détails de l'utilisateur: \(error)")
                return
            }

            if let data = data {
                if let response = try? JSONSerialization.jsonObject(with: data, options: []) {
                    if let userData = response as? [String: Any] {
                        DispatchQueue.main.async {
                            self.firstName = userData["prenom"] as? String ?? ""
                            self.lastName = userData["nom"] as? String ?? ""
                        }
                    }
                }
            }
        }
        task.resume()
    }

    func deleteProfile() {
            // Affichage de la boîte de dialogue de confirmation
            let alertController = UIAlertController(
                title: "Confirmer la suppression",
                message: "Êtes-vous sûr de vouloir supprimer votre profil ? Cette action est irréversible.",
                preferredStyle: .alert
            )

            // Action "Annuler"
            let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)

            // Action "Confirmer"
            let confirmAction = UIAlertAction(title: "Confirmer", style: .destructive) { _ in
                // Si l'utilisateur confirme la suppression, procéder à la suppression
                fetchUserByEmail(email: self.email) { userId in
                    guard let userId = userId else {
                        print("Utilisateur non trouvé avec l'email: \(self.email)")
                        return
                    }

                    guard let url = URL(string: "https://520d-197-21-87-58.ngrok-free.app/user/\(userId)") else {
                        print("URL incorrecte")
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "DELETE"

                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("Erreur lors de la suppression du profil: \(error)")
                            return
                        }

                        // Suppression réussie, mise à jour de la variable pour activer la navigation
                        DispatchQueue.main.async {
                            self.isUserDeleted = true
                            self.navigateTologin = true  // Active la navigation vers ProfileView
                        }
                    }
                    task.resume()
                }
            }

            // Ajout des actions à l'alerte
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)

            // Présentation de l'alerte sur le thread principal
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
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
}


import SwiftUI

struct editProfileView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            VStack {
                // Titre avec une police et couleur similaire à Android
                Text("Update Profile")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                VStack(spacing: 20) {
                    // Champs de texte avec un design épuré
                    inputField(label: "First Name", text: $firstName)
                    inputField(label: "Last Name", text: $lastName)
                    inputField(label: "Email", text: $email)
                }
                .padding(.horizontal)

                // Bouton de mise à jour
                Button(action: updateProfile) {
                    Text("Update Profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.top, 30)

                // Bouton Reset Password
                NavigationLink(destination: ForgetPasswordView(email: $email).toolbar(.visible)) {
                              Text("Reset Password")
                                  .font(.system(size: 16, weight: .semibold))
                                  .foregroundColor(.blue)
                                  .padding()
                                  .frame(maxWidth: .infinity)
                                  .background(Color.blue.opacity(0.2))
                                  .cornerRadius(12)
                                  .shadow(radius: 5)
                          }
                .padding(.top, 10)

                // Bouton Delete Profile
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .background(Color.white)  // Fond blanc
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.horizontal)

            // Boîte de dialogue pour supprimer le profil
            if showDeleteConfirmation {
                deleteAccountDialog
            }
        }
    }

    // Champ de saisie personnalisé
    private func inputField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray) // Gris pour le texte du label

            TextField("Enter your \(label.lowercased())", text: text)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                .shadow(radius: 5)
                .padding(.bottom, 16)
        }
    }

    // Dialog de confirmation pour la suppression du compte
    private var deleteAccountDialog: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("Are you sure you want to delete your account? This action is irreversible.")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .shadow(radius: 10)

                HStack {
                    Button(action: {
                        // Annuler la suppression
                        showDeleteConfirmation = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button(action: {
                        // Effectuer la suppression du profil
                        deleteProfile()
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .shadow(radius: 20)
            .padding(.horizontal)
        }
    }



    func updateProfile() {
        let updateData: [String: Any] = [
            "nom": firstName,
            "prenom": lastName,
            "email": email
        ]

        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://520d-197-21-87-58.ngrok-free.app/user/email/\(encodedEmail)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updateData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding data: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating profile: \(error)")
                return
            }

            if let data = data, let response = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("Profile updated successfully: \(response)")
            }
        }
        task.resume()
    }

  

    func deleteProfile() {
        // Affichage de la boîte de dialogue de confirmation
        let alertController = UIAlertController(
            title: "Confirmer la suppression",
            message: "Êtes-vous sûr de vouloir supprimer votre profil ? Cette action est irréversible.",
            preferredStyle: .alert
        )

        // Action "Annuler"
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)

        // Action "Confirmer"
        let confirmAction = UIAlertAction(title: "Confirmer", style: .destructive) { _ in
            fetchUserByEmail(email: self.email) { userId in
                guard let userId = userId else {
                    print("Utilisateur non trouvé avec l'email: \(self.email)")
                    return
                }

                guard let url = URL(string: "https://520d-197-21-87-58.ngrok-free.app/user/\(userId)") else {
                    print("URL incorrecte")
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Erreur lors de la suppression du profil: \(error)")
                        return
                    }

                    // Suppression réussie, mise à jour de la variable pour activer la navigation
                    DispatchQueue.main.async {
                        print("Profile deleted successfully")
                    }
                }
                task.resume()
            }
        }

        // Ajout des actions à l'alerte
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)

        // Présentation de l'alerte sur le thread principal
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
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
}





    
    
    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                editProfileView()
                ProfileView()
            }
        }
    }

