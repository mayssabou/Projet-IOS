import SwiftUI

struct OTPView: View {
    @Binding var email: String
    @State private var otp: String = ""
    @State private var isOTPSuccess: Bool = false
    @State private var errorMessage: String = ""
    @State private var isOTPVerified: Bool = false  // New state for navigation
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Vérification OTP")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.blue)
                
                Text("Un code OTP a été envoyé à \(email)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.green)
                
                SecureField("Entrez le code OTP", text: $otp)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(isOTPSuccess ? Color.green : Color.blue, lineWidth: 2))
                    .padding([.horizontal, .top])
                    .autocapitalization(.none)
                    .keyboardType(.numberPad)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }
                
                Button(action: verifyOTP) {
                    Text("Vérifier")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .disabled(otp.isEmpty)
               
                Spacer()
                
                // NavigationLink for navigating to ForgetPasswordView
                NavigationLink(destination: ForgetPasswordView(email: $email), isActive: $isOTPVerified) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
    
    func verifyOTP() {
        // Check if OTP is empty
        if otp.isEmpty {
            errorMessage = "Le code OTP ne peut pas être vide."
            return
        }

        // Logic for OTP validation
        let url = URL(string: "https://8076-197-3-6-252.ngrok-free.app/auth/verify-email")
        
        let body: [String: Any] = [
            "email": email,
            "otp": otp
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
                        self.errorMessage = "Erreur de validation du code OTP: \(error.localizedDescription)"
                        return
                    }
                    
                    // Check the response from the server
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 201 {
                            // OTP successfully validated
                            self.isOTPSuccess = true
                            self.errorMessage = ""
                            
                            // Set isOTPVerified to true to trigger the navigation
                            self.isOTPVerified = true
                        } else {
                            self.isOTPSuccess = false
                            self.errorMessage = "Le code OTP est incorrect ou expiré."
                        }
                    } else {
                        self.errorMessage = "Réponse du serveur invalide."
                    }
                }
            }
            task.resume()
        } catch {
            self.errorMessage = "Erreur lors de la création de la requête."
        }
    }
}
