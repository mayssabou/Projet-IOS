import SwiftUI
import WebKit

class ViewModel: ObservableObject {
    @Published var info: String = "Waiting for data..."

    func updateData(with data: String) {
        DispatchQueue.main.async {
            self.info = data
        }
    }
}

struct WebView: UIViewRepresentable {
    var url: URL
    @ObservedObject var viewModel: ViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        // Assurez-vous que la caméra est autorisée pour les applications Web.
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "iosListener")
        webConfiguration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)

        // Gérer la demande de permission de la caméra.
        let cameraPermissionScript = """
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            navigator.mediaDevices.getUserMedia({ video: true })
            .then(function(stream) {
                console.log('Camera access granted');
                window.webkit.messageHandlers.iosListener.postMessage('Camera access granted');

            })
            .catch(function(error) {
                console.log('Camera access denied');
                window.webkit.messageHandlers.iosListener.postMessage('Camera access denied');

            });
        }
        """
        let script = WKUserScript(source: cameraPermissionScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webConfiguration.userContentController.addUserScript(script)
        
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let data = message.body as? String {
                self.viewModel.updateData(with: data)
            }
        }
    }
}

struct PoseTrackerView: View {
    @StateObject var viewModel = ViewModel()
    @State private var selectedExercise = "squat"
    @State private var selectedDifficulty = "easy"
    @State private var showWebView = false
    @State private var token = "4de8d13e-362c-47ba-b16b-5fc519e71d27"


    var body: some View {
        VStack {
            if showWebView {
                WebView(
                    url: constructURL(
                        token: token,
                        exercise: selectedExercise,
                        difficulty: selectedDifficulty
                    ),
                    viewModel: viewModel
                )
                .edgesIgnoringSafeArea(.all)
            } else {
                VStack {
                    Text("Select Exercise and Difficulty")
                        .font(.headline)
                        .padding()

                    Picker("Exercise", selection: $selectedExercise) {
                        Text("Squat").tag("squat")
                        Text("Push-up").tag("pushup")

                       // Text("Push Up").tag("push-up")
                        //
                        //Text("Jumping Jack").tag("jumping-jack")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Picker("Difficulty", selection: $selectedDifficulty) {
                        Text("Easy").tag("easy")
                        Text("Medium").tag("medium")
                        Text("Hard").tag("hard")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Button(action: {
                        showWebView = true
                    }) {
                        Text("Start Exercise")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    private func constructURL(token: String,exercise: String, difficulty: String) -> URL {
        let baseUrl = "https://app.posetracker.com/pose_tracker/tracking"
        var components = URLComponents(string: baseUrl)!
        components.queryItems = [
            URLQueryItem(name: "token", value: token),
            URLQueryItem(name: "exercise", value: exercise),
            URLQueryItem(name: "difficulty", value: difficulty),
            URLQueryItem(name: "width", value: "350"),
            URLQueryItem(name: "height", value: "350"),
            URLQueryItem(name: "progression", value: "true"),

        ]
        return components.url!
    }
}

