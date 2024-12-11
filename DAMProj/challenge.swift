//
//  challenge.swift
//  DAMProj
//
//  Created by Mac Mini 1 on 21/11/2024.
//

import SwiftUI

struct ChallengeView: View {
    @State private var playerOneName: String = "Player 1"
    @State private var playerTwoName: String = "Player 2"
    @State private var isChallengeStarted = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                
                Image("challenge")  // Nom de l'image dans vos assets
                             .resizable()  // Permet de redimensionner l'image
                             .scaledToFit()  // Pour maintenir les proportions de l'image
                             .frame(width: 300, height: 200)  // Définir la taille de l'image
                             .padding()
                // Titre de la vue
                Text("Challenge Between Players")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 40)

                // Affichage des joueurs
                VStack(spacing: 20) {
                    Text("Player 1: \(playerOneName)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text("Player 2: \(playerTwoName)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                // Bouton pour démarrer le challenge
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
                .padding(.top, 30)
                               .navigationDestination(isPresented: $isChallengeStarted) {
                                   // Naviguer vers la vue PosetrackerView
                                   PoseTrackerView(
                                                        
                                                      )                               }


                Spacer()
            }
            .padding()
            .background(Color.white)  // Fond bleu ciel
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.horizontal)
        }
    }

    // Fonction pour démarrer le challenge
    func startChallenge() {
        // Logique de démarrage du challenge (ici, on affiche simplement une nouvelle vue)
        isChallengeStarted = true
    }
}

struct ChallengeGameplayView: View {
    var playerOne: String
    var playerTwo: String

    var body: some View {
        VStack {
            Text("Challenge in Progress")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 40)
            
            Text("Player 1: \(playerOne)")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
            
            Text("Player 2: \(playerTwo)")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
            
            Spacer()
            
            Text("Gameplay area will be here")
                .font(.system(size: 20))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(25)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ChallengeView()
        }
    }
}

