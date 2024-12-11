import SwiftUI

struct ForgetPasswordView: View {
    @Binding var email: String
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State var isConfirmed = false
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 50)

                Text("Reset Your Password")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.blue)
                    .padding(.bottom, 60)

                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color.gray)
                    
                    SecureField("Enter your new password", text: $password)
                        .padding(15)
                        .autocapitalization(.none)
                        .background(
                               RoundedRectangle(cornerRadius: 15)
                                   .fill(LinearGradient(
                                       gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing
                                   ))
                           )
                        .shadow(radius: 5)
                        .padding(.bottom, 15)
                }
                
                VStack(alignment: .leading) {
                    Text("Confirm Password")
                        .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color.gray)
                    SecureField("Confirm your new password", text: $confirmPassword)
                        .padding(15)
                        .autocapitalization(.none)
                        .background(
                               RoundedRectangle(cornerRadius: 15)
                                   .fill(LinearGradient(
                                       gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing
                                   ))
                           )
                        .shadow(radius: 5)
                        .padding(.bottom, 15)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 10)
                }

                Button(action: confirmPasswordReset) {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .semibold))
                                 .foregroundColor(.white)
                                 .padding()
                                 .frame(maxWidth: .infinity)
                                 .background(Color.blue)
                                 .cornerRadius(10)
                }
                .padding(.top)
                .navigationDestination(isPresented: $isConfirmed, destination: {ProfileView()})
                Spacer()
            }
            .padding()
            .padding(.horizontal)
        }
    }
    
    func confirmPasswordReset() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }
        let url = URL(string:  "https://8076-197-3-6-252.ngrok-free.app/auth/forgot-password")
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
                        self.errorMessage = "Error: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = nil
                        isConfirmed = true
                    }
                }
            }
            task.resume()
        } catch {
            self.errorMessage = "Error while creating request."
        }
        errorMessage = nil
        print("Password reset confirmed")
    }
}

struct ConfirmMail: View {
    @State var email: String = ""
    @State private var errorMessage: String? = nil
    @State private var navigate = false
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 50)
                Text("Enter Your Email")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.blue)
                    .padding(.bottom, 60)

                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color.gray)

                    TextField("Enter your email address", text: $email)
                        .padding(15)
                        .autocapitalization(.none)
                        .background(
                               RoundedRectangle(cornerRadius: 15)
                                   .fill(LinearGradient(
                                       gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing
                                   ))
                           )
                        .shadow(radius: 5)
                        .padding(.bottom, 15)
                }

                // Message d'erreur
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 10)
                }

                // Bouton pour vérifier l'email
                NavigationLink(destination: OTPView(email: $email), isActive: $navigate) {
                    EmptyView()
                }
                Button(action: sendVerificationEmail) {
                    Text("Check Email")
                        .font(.system(size: 16, weight: .semibold))
                                 .foregroundColor(.white)
                                 .padding()
                                 .frame(maxWidth: .infinity)
                                 .background(Color.blue)
                                 .cornerRadius(10)
                }
                .padding(.top)
                Spacer()
            }
            .padding()
        }
    }

    func sendVerificationEmail() {
        if email.isEmpty || !isValidEmail(email) {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        let url = URL(string: "https://8076-197-3-6-252.ngrok-free.app/auth/generate-email")!  // Remplacer par l'URL correcte
        let body = [
            "email": email,
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Error: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = nil
                        // Naviguer vers l'écran OTP après l'envoi réussi de l'email
                        // Ici on pourrait utiliser une NavigationLink ou modifier une variable d'état pour déclencher une vue OTP
                    }
                }
            }
            task.resume()
            DispatchQueue.main.async {
                navigate = true
            }
        } catch {
            self.errorMessage = "An error occurred while processing the request."
        }
    }

    // Fonction pour vérifier la validité de l'email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}

// Prévisualisation
struct ForgetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // ForgetPasswordView(email: )
            ConfirmMail()
        }
    }
}
//Maissa1230?0
///Mmaissa@esprit.tn
//Maissabs1230?
