import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage: String?
    @State private var emailError: String?
    @State private var passwordError: String?

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 200)  // Décalage vers le bas

                VStack {
                    // Titre avec une belle police et ombre
                    Text("OMA App")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .foregroundColor(Color.purple)
                        .shadow(radius: 2)

                    Text("Sign In")
                        .font(Font.custom("Outfit", size: 18))
                        .fontWeight(.regular)
                        .padding(.top, 5)
                        .foregroundColor(Color.pink)

                    // Formulaire de connexion (Email et mot de passe)
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(Font.custom("Outfit", size: 14))
                            .foregroundColor(Color.pink)
                        
                        TextField("Enter your email", text: $email)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(gradient: Gradient(colors: [emailError != nil ? Color.red.opacity(0.3) : Color.blue.opacity(0.1), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .shadow(radius: 5)
                            .padding(.bottom, 15)
                            .onChange(of: email) { newValue in
                                validateEmail(newValue)
                            }

                        if let emailError = emailError {
                            Text(emailError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, 10)
                        }

                        Text("Password")
                            .font(Font.custom("Outfit", size: 14))
                            .foregroundColor(Color.pink)
                        
                        SecureField("Enter your password", text: $password)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(gradient: Gradient(colors: [passwordError != nil ? Color.red.opacity(0.3) : Color.blue.opacity(0.1), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .shadow(radius: 5)
                            .onChange(of: password) { newValue in
                                validatePassword(newValue) // Validation dès que l'utilisateur tape
                            }

                        if let passwordError = passwordError {
                            Text(passwordError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, 10)
                        }
                    }
                    .padding(.top, 16)

                    HStack {
                        Spacer()
                        NavigationLink {
                            ConfirmMail()
                            
                        } label: {
                            Text("Forget Password ?")
                                .font(Font.custom("Outfit", size: 14))
                                .foregroundColor(Color.pink)
                        }
                    }

                    Button {
                        login()                    } label: {
                        Text("Login")
                            .fontWeight(.bold)
                            .font(Font.custom("Outfit", size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.white)  // Texte blanc
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    .padding(.top)

                    // Affichage des messages d'erreur si la connexion échoue
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top)
                            .font(.body)
                            .transition(.slide)
                    }
                }
                .padding()
                .padding(.horizontal)

                Text("Or")
                    .font(Font.custom("Outfit", size: 16))
                    .foregroundColor(Color.pink)
                    .padding(.top)

                // Options de connexion avec des images cliquables
                VStack(spacing: 16) {
                    // Bouton "Continue with Apple"
                    Button(action: {
                        print("Apple login clicked")
                    }) {
                        Image("Applelogo")  // Remplacer par ton image Apple
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)  // Image plus petite
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)

                    Button(action: {
                        print("Google login clicked")
                    }) {
                        Image("googlelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)  // Image plus petite
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)

                    // Bouton "Continue with Facebook"
                    Button(action: {
                        print("Facebook login clicked")
                    }) {
                        Image("fblogo")  // Remplacer par ton image Facebook
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)  // Image plus petite
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding()

                NavigationLink(destination: SignUpView()) {
                    Text("Create an Account")
                        .font(Font.custom("Outfit", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.pink)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 200)
                }
                Spacer()
                NavigationLink(destination: ConfirmMail(email: email), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
        }
    }

    func login() {
        // Réinitialisation des messages d'erreur à chaque tentative
        emailError = nil
        passwordError = nil
        errorMessage = nil

        // Vérification si les champs sont vides ou invalides
        if email.isEmpty {
            emailError = "Email cannot be empty."
        } else if !isValidEmail(email) {
            emailError = "Invalid email format."
        }

        if password.isEmpty {
            passwordError = "Password cannot be empty."
        } else if !isValidPassword(password) {
            passwordError = "Password must be at least 8 characters long, including letters, numbers, and symbols."
        }

        // Si un des champs est vide ou invalide, on arrête la tentative de connexion
        if emailError != nil || passwordError != nil {
            return
        }

        // Si les erreurs ont été corrigées, réinitialisation des erreurs
        let url = URL(string: "https://37de-102-159-74.ngrok-free.app/auth/login")
        let body = [
            "email": email,
            "password": password
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Erreur de connexion: \(error.localizedDescription)"
                    } else {
                        // Connexion réussie
                        self.isLoggedIn = true
                        self.errorMessage = nil
                    }
                }
            }
            task.resume()
        } catch {
            self.errorMessage = "Erreur lors de la création de la requête."
        }
    }

    func validateEmail(_ email: String) {
        if email.isEmpty {
            emailError = "Email cannot be empty."
        } else if !isValidEmail(email) {
            emailError = "Invalid email format."
        } else {
            emailError = nil  // Réinitialiser l'erreur si l'email est valide
        }
    }

    func validatePassword(_ password: String) {
        if password.isEmpty {
            passwordError = "Password cannot be empty."
        } else if !isValidPassword(password) {
            passwordError = "Password must be at least 8 characters long, including letters, numbers, and symbols."
        } else {
            passwordError = nil  // Réinitialiser l'erreur si le mot de passe est valide
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
