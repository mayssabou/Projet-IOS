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
                List(sports, id: \.id) { sport in // Use the `id` for the `id` parameter
                    // Using NavigationLink to navigate to the corresponding view
                    NavigationLink(
                        destination: destinationView(for: sport),
                        tag: sport,
                        selection: $selectedSport
                    ) {
                        SportCard(sport: sport)
                    }
                }
                .navigationTitle("GoVibe")
                .navigationBarItems(trailing:
                    NavigationLink(destination: ProfileView(email: email)) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                )
            }
            .padding()
        }
    }
    
    // Destination View based on the selected sport
    private func destinationView(for sport: SportItem) -> some View {
        switch sport.name {
        case "Yoga":
            return AnyView(YogaView(email: email)) // Replace with your YogaView
        case "Squat":
            return AnyView(SquatView(email: email)) // Replace with your YogaView
        case "Push-up":
            return AnyView(PushupView(email: email)) // Replace with your YogaView
        case "Running":
            return AnyView(RunningView(email: email)) // Replace with your YogaView
       
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

struct SportItem: Identifiable, Hashable { // Conform to Hashable
    let id = UUID()
    let name: String
    let imageRes: String // Nom de l'image dans les assets
}

