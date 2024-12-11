import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    
    // Navigation state
   
    @State private var navigateToHome = false
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 20)  // Décalage vers le bas

                VStack {
                    Image("applogo")
                    // Titre avec une belle police et ombre
                    Text("GoVibe")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.blue)
                    Text("Sign In")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.green)

                    // Formulaire de connexion (Email et mot de passe)
                    VStack(alignment: .leading) {
                        
                        
                        TextField("Enter your email", text: $email)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(gradient: Gradient(colors: [emailError != nil ? Color.red.opacity(0.1) : Color.blue.opacity(0.1), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
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

                       
                        
                        SecureField("Enter your password", text: $password)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(gradient: Gradient(colors: [passwordError != nil ? Color.red.opacity(0.1) : Color.blue.opacity(0.1), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
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
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.green)
                        }
                    }

                    Button {
                        login()  // Trigger login logic
                    } label: {
                        Text("Login")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)

                    // Display error messages if login fails
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
                    .font(.system(size: 16))
                    .foregroundColor(Color.green)
                    .padding(.top)

                // Horizontal social login buttons
                HStack(spacing: 20) {
                    Button(action: { print("Apple login clicked") }) {
                        Image("Applelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)

                    Button(action: { print("Google login clicked") }) {
                        Image("googlelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)

                    Button(action: { print("Facebook login clicked") }) {
                        Image("fblogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                .padding()

                NavigationLink(destination: SignUpView()) {
                    Text("Create an Account")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.green)
                }

                Spacer()
            }
            // Programmatic navigation to ProfileView after login
            .background(
                NavigationLink(destination: HomeView(email: email), isActive: $navigateToHome){
                             
                    EmptyView()
                }
            )
        }
    }

    func login() {
        // Reset error messages
        emailError = nil
        passwordError = nil
        errorMessage = nil

        // Validate input fields
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

        // Stop login attempt if any error exists
        if emailError != nil || passwordError != nil {
            return
        }

        // Send login request
        let url = URL(string:  "https://8076-197-3-6-252.ngrok-free.app/auth/login")
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
                        // Successful login
                        self.isLoggedIn = true
                        self.errorMessage = nil
                        // Navigate to ProfileView
                        self.navigateToHome = true
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
            emailError = nil  // Reset error if valid
        }
    }

    func validatePassword(_ password: String) {
        if password.isEmpty {
            passwordError = "Password cannot be empty."
        } else if !isValidPassword(password) {
            passwordError = "Password must be at least 8 characters long, including letters, numbers, and symbols."
        } else {
            passwordError = nil  // Reset error if valid
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
