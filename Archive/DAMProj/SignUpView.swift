import SwiftUI

struct SignUpView: View {
    @State private var firstName = ""  // Prénom
    @State private var lastName = ""   // Nom
    @State private var email = ""      // Email
    @State private var password = ""   // Mot de passe
    @State private var firstNameError: String?  // Erreur prénom
    @State private var lastNameError: String?   // Erreur nom
    @State private var emailError: String?      // Erreur email
    @State private var passwordError: String?   // Erreur mot de passe
    @State private var errorMessage: String?   // Message d'erreur global

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 100)

                VStack {
                    Text("OMA App")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .foregroundColor(Color.purple)
                        .shadow(radius: 2)

                    Text("Sign Up")
                        .font(.custom("Outfit", size: 18))
                        .fontWeight(.regular)
                        .padding(.top, 5)
                        .foregroundColor(Color.pink)

                    // Formulaire d'inscription
                    VStack(alignment: .leading) {
                        // Prénom
                        formField(title: "First Name", text: $firstName, error: $firstNameError) { newValue in
                            validateFirstName(newValue)
                        }

                        // Nom de famille
                        formField(title: "Last Name", text: $lastName, error: $lastNameError) { newValue in
                            validateLastName(newValue)
                        }

                        // Email
                        formField(title: "Email", text: $email, error: $emailError) { newValue in
                            validateEmail(newValue)
                        }

                        // Mot de passe
                        formField(title: "Password", text: $password, error: $passwordError) { newValue in
                            validatePassword(newValue)
                        }
                    }
                    .padding(.top, 16)

                    // Bouton d'inscription
                    Button {
                        signUp()  // Appel à la fonction signUp() lors du clic
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .font(.custom("Outfit", size: 16))
                            .foregroundColor(Color.white)  // Texte blanc
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))  // Dégradé rose-violet
                            .cornerRadius(15)
                    }
                    .padding(.top)

                    // Affichage des messages d'erreur généraux
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

                Spacer()

                // Lien vers la page de connexion
                NavigationLink {
                    LoginView()
                } label: {
                    Text("Already have an account? Log in")
                        .font(.custom("Outfit", size: 16))
                        .foregroundColor(Color.pink)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 100)
                }

                Spacer()
            }
        }
        .navigationTitle("Sign Up")
        .toolbar(.hidden)
    }

    // Fonction de validation pour chaque champ
    func signUp() {
        // Réinitialisation des messages d'erreur à chaque tentative
        firstNameError = nil
        lastNameError = nil
        emailError = nil
        passwordError = nil
        errorMessage = nil

        // Vérification des champs
        if firstName.isEmpty {
            firstNameError = "First name cannot be empty."
        }

        if lastName.isEmpty {
            lastNameError = "Last name cannot be empty."
        }

        if email.isEmpty {
            emailError = "Email cannot be empty."
        } else if !isValidEmail(email) {
            emailError = "Invalid email format."
        }

        if password.isEmpty {
            passwordError = "Password cannot be empty."
        }
         else if !isValidPassword(password) {
            passwordError = "Password must be at least 8 characters long, including letters, numbers, and symbols."
        }
        
        // Si un des champs est vide ou invalide, on arrête la tentative de connexion
        if firstNameError != nil || lastNameError != nil || emailError != nil || passwordError != nil {
            return
        }

        // Si les erreurs ont été corrigées, on envoie les données
        let url = URL(string: "https://37de-197-3-6-252.ngrok-free.app/auth/signup")
        let body = [
            "prenom": firstName,
            "nom": lastName,
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
                        self.errorMessage = "Error: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = nil
                    }
                }
            }
            task.resume()
        } catch {
            self.errorMessage = "Error while creating request."
        }
    }

    // Fonction pour valider le prénom
    func validateFirstName(_ firstName: String) {
        if firstName.isEmpty {
            firstNameError = "First name cannot be empty."
        } else {
            firstNameError = nil
        }
    }

    // Fonction pour valider le nom
    func validateLastName(_ lastName: String) {
        if lastName.isEmpty {
            lastNameError = "Last name cannot be empty."
        } else {
            lastNameError = nil
        }
    }

    func validateEmail(_ email: String) {
        if email.isEmpty {
            emailError = "Email cannot be empty."
        } else if !isValidEmail(email) {
            emailError = "Invalid email format."
        } else {
            emailError = nil
        }
    }

    func validatePassword(_ password: String) {
        if password.isEmpty {
            passwordError = "Password cannot be empty."
        } else if !isValidPassword(password) {
            passwordError = "Password must be at least 8 characters long, including letters, numbers, and symbols."
        } else {
            passwordError = nil
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,16}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }

    private func formField(title: String, text: Binding<String>, error: Binding<String?>, validation: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("Outfit", size: 14))
                .foregroundColor(Color.pink)

            TextField("Enter your \(title)", text: text)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(gradient: Gradient(colors: [error.wrappedValue != nil ? Color.red.opacity(0.3) : Color.blue.opacity(0.1), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .shadow(radius: 5)
                .onChange(of: text.wrappedValue) { newValue in
                    validation(newValue)
                }

            if let errorMessage = error.wrappedValue {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.bottom, 10)
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

