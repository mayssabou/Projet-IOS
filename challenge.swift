//
//  challenge.swift
//  DAMProj
//
//  Created by Mac Mini 1 on 21/11/2024.
//

import SwiftUI
struct ChallengeView: View {
 
    @State private var isChallengeStarted = false
    var email: String  // Accept email as a parameter

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if email.isEmpty {
                    Text("Error: No email passed.")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Continue with the normal content
                    Text("Welcome, \(email)")
                        .font(.title)
                        .foregroundColor(.green)
                        .padding()

                    Image("challenge")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 200)
                        .padding()

                    Button(action: {
                        startChallenge()
                    }) {
                        Text("Start Challenge")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 30)
                    .navigationDestination(isPresented: $isChallengeStarted) {
                        PoseTrackerView(email: email)  // Pass email to PoseTrackerView
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.horizontal)
        }
        .onAppear {
            // Check if email is passed correctly
            if email.isEmpty {
                print("Error: Email is missing in ChallengeView")
            }
        }
    }

    // Fonction pour démarrer le challenge
    func startChallenge() {
        // Logique de démarrage du challenge (ici, on affiche simplement une nouvelle vue)
        isChallengeStarted = true
    }
}

/*
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ChallengeView()
        }
    }
}*/

