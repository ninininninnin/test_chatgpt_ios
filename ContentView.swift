import SwiftUI

struct ContentView: View {
    @State private var userInput = ""
    @State private var chatResponse = ""
    
    var body: some View {
        VStack {
            Text("ChatGPT Example")
                .font(.title)
            
            TextField("Enter text", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                sendChatRequest()
            }) {
                Text("Send")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text(chatResponse)
                .padding()
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    func sendChatRequest() {
        let apiKey = Constants.apiKey
        let apiUrl = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let messages = [
            Message(role: "system", content: "You are a helpful assistant."),
            Message(role: "user", content: userInput)
        ]
        
        let requestData = RequestData(messages: messages, model: "gpt-3.5-turbo")
        
        let jsonEncoder = JSONEncoder()
        guard let requestDataJson = try? jsonEncoder.encode(requestData) else {
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestDataJson
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(ChatResponse.self, from: data)
                    let reply = response.choices[0].message.content
                    DispatchQueue.main.async {
                        chatResponse = reply
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

struct Message: Codable {
    let role: String
    let content: String
}

struct RequestData: Codable {
    let messages: [Message]
    let model: String
}
