import SwiftUI

struct OTPView: View {
    var email: String
    @State private var otp: String = ""
    @State private var isOTPSuccess: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Titre principal
                Text("Vérification OTP")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.purple)
                    .padding(.top, 40)
                
                // Message informatif
                Text("Un code OTP a été envoyé à \(email)")
                    .font(.subheadline)
                    .foregroundColor(Color.pink)
                    .padding(.bottom, 20)
                
                // Champ OTP
                SecureField("Entrez le code OTP", text: $otp)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(isOTPSuccess ? Color.green : Color.blue, lineWidth: 2))
                    .padding([.horizontal, .top])
                    .autocapitalization(.none)
                    .keyboardType(.numberPad)
                
                // Affichage du message d'erreur s'il y en a
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }
                
                // Bouton Vérifier
                Button(action: verifyOTP) {
                    Text("Vérifier")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)
                .disabled(otp.isEmpty)
                .navigationDestination(isPresented: $isOTPSuccess) {
                    ForgetPasswordView()
                }
                Spacer()
            }
            .padding()
        }
    }
    
    func verifyOTP() {
        // Logique de validation OTP
        let url = URL(string: "https://37de-197-3-6-252.ngrok-free.app/auth/verify-email")!
        
        let body: [String: Any] = [
            "email": "Ali.ammari@esprit.tn",
            "otp": otp
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
                        self.errorMessage = "Erreur de validation du code OTP: \(error.localizedDescription)"
                        return
                    }
                    
                    
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                        // OTP validé avec succès
                        self.isOTPSuccess = true
                        self.errorMessage = ""
                        
                        // Naviguer vers la page d'accueil ou une autre vue
                    } else {
                        self.isOTPSuccess = false
                        self.errorMessage = "Le code OTP est incorrect."
                    }
                }
            }
            task.resume()
        } catch {
            self.errorMessage = "Erreur lors de la création de la requête."
        }
    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OTPView(email: "Ali.Ammari@esprit.tn")
    }
}
