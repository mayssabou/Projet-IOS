import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL
    @ObservedObject var viewModel: ViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "iosListener")
        webConfiguration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
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
                DispatchQueue.main.async {
                    self.viewModel.updateData(with: data)
                }
            }
        }
    }
}

class ViewModel: ObservableObject {
    @Published var info: String = "Waiting for data..."

    func updateData(with data: String) {
        self.info = data
    }
}
func fetchTrackingURL(poseData: [String: Any], completion: @escaping (String?) -> Void) {
    guard let url = URL(string: "https://d092-196-232-79-254.ngrok-free.app/track/generate-url") else { return }
   
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
   
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: poseData, options: [])
    } catch {
        print("Failed to encode pose data: \(error)")
        completion(nil)
        return
    }
   
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error fetching URL: \(error)")
            completion(nil)
            return
        }
       
        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }
       
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let trackingUrl = json["trackingUrl"] as? String {
                completion(trackingUrl)
            } else {
                completion(nil)
            }
        } catch {
            print("Error parsing response: \(error)")
            completion(nil)
        }
    }.resume()
}

struct PoseTracker: View {
    @StateObject private var viewModel = ViewModel()
    @State private var trackingUrl: String? = nil

    var body: some View {
        VStack {
            Text(viewModel.info)
                .padding()
           
            if let url = trackingUrl, let validURL = URL(string: url) {
                WebView(url: validURL, viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Loading tracking data...")
                    .onAppear {
                        let poseData: [String: Any] = [
                            "exercise": "squat",
                            "difficulty": "easy",
                            "skeleton": true,
                            "width": 350,
                            "height": 350
                        ]
                        fetchTrackingURL(poseData: poseData) { url in
                            DispatchQueue.main.async {
                                self.trackingUrl = url
                            }
                        }
                    }
            }
        }
    }
}

