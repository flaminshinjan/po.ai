import SwiftUI

struct ConversationView: View {
    @StateObject private var viewModel = ConversationViewModel()
    @State private var isListening = false
    @State private var scale: CGFloat = 1.0 // Scale for blob animation

    var body: some View {
        VStack(spacing: 0) {
            // Fixed Position: Text at the top
            Text(viewModel.isProcessing ? "Let me think..." : viewModel.responseText)
                .font(.system(size: 35)) // Plus Jakarta Sans font
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .lineLimit(4)
                .truncationMode(.tail)
                .padding(.top, 40)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading) // Stretch width but align to left
            
            Spacer() // Push Blob to the middle
            
            // Blob in the middle with breathing effect
            Circle()
                .fill(Color(hex: "EB8D70")) // Blob Color: #EB8D70
                .frame(width: 280, height: 280)
                .scaleEffect(scale) // Apply scale effect
                .animation(
                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: scale
                )
                .onAppear {
                    // Start scaling animation
                    scale = 1.2 // Scales up to 120%
                }
            
            Spacer() // Push Button to the bottom
            
            // Button at the bottom
            Button(action: {
                if isListening {
                    // Stop listening and process input
                    viewModel.stopListening { text in
                        isListening = false
                        viewModel.processText(text: text)
                    }
                } else {
                    // Start listening
                    isListening = true
                    viewModel.startListening()
                }
            }) {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    Text(isListening ? (viewModel.isProcessing ? "Processing..." : "Stop Listening") : "Let’s Chat")
                        .font(Font.custom("PlusJakartaSans-SemiBold", size: 16)) // Plus Jakarta Sans font
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isProcessing ? Color.gray : Color(hex: "EB8D70")) // Button matches blob color
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .padding(.horizontal)
            .disabled(viewModel.isProcessing) // Disable button when processing
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    ConversationView()
}
