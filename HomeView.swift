import SwiftUI

struct HomeView: View {
    let sports = [
        SportItem(name: "Squat", imageRes: "squat"),
        SportItem(name: "Push-up", imageRes: "pushup"),
        SportItem(name: "Running", imageRes: "running"),
        SportItem(name: "Yoga", imageRes: "yoga")
    ]
    
    var email: String
    @State private var selectedSport: SportItem?
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    // Top Title
                    Text("Push Yourself")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 16)
                    
                    // Sports List
                    List(sports, id: \.id) { sport in
                        NavigationLink(
                            destination: destinationView(for: sport),
                            tag: sport,
                            selection: $selectedSport
                        ) {
                            SportCard(sport: sport)
                        }
                    }
                    .navigationTitle("GoVibe")
              
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // Challenge tab
            ChallengeView(email: email)  // Pass email directly here
                         .tabItem {
                             Image(systemName: "flame.fill")
                             Text("Challenge")
                         }
            ProfileView(email: email)  // Pass email directly to the ProfileView
                           .tabItem {
                               Image(systemName: "person.crop.circle.fill")
                               Text("Profile")
                           }
        }
    }
    
    // Destination View based on the selected sport
    private func destinationView(for sport: SportItem) -> some View {
        switch sport.name {
        case "Yoga":
            return AnyView(YogaView(email: email))
        case "Squat":
            return AnyView(SquatView(email: email))
        case "Push-up":
            return AnyView(PushupView(email: email))
        case "Running":
            return AnyView(RunningView(email: email))
        default:
            return AnyView(Text("Sport non reconnu"))
        }
    }
}

struct SportCard: View {
    let sport: SportItem
    
    var body: some View {
        HStack {
            Image(sport.imageRes)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(8)
            
            Text(sport.name)
                .font(.title2)
                .foregroundColor(.primary)
                .padding(8)
            
            Spacer()
        }
        .frame(height: 150)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.2)))
        .padding(.vertical, 8)
    }
}

struct SportItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageRes: String
}
