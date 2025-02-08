import SwiftUI

struct OpenAIKeyTester: View {
    @State private var testResult: String = "Tap to test API key"
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("OpenAI API Key Test")
                .font(.title)
            
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                Text(testResult)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                Task {
                    isLoading = true
                    testResult = await OpenAIService.shared.testAPIKey()
                    isLoading = false
                }
            }) {
                Text("Test API Key")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    OpenAIKeyTester()
} 