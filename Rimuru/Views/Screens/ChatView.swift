import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // --- GLASS HEADER ---
            HStack(spacing: 15) {
                ZStack {
                    Circle().fill(Color.blue.opacity(0.2)).frame(width: 48, height: 48)
                    Image("rimuru")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rimuru Intelligence").font(.custom("Poppins-Bold", size: 16))
                    HStack(spacing: 5) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("Active Now").font(.custom("Poppins-Regular", size: 12)).foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding().background(.ultraThinMaterial).foregroundColor(.white)
            
            // --- CHAT MESSAGES ---
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(viewModel.messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id)
                        }
                        
                        if viewModel.isTyping {
                            HStack {
                                ProgressView().tint(.white.opacity(0.5))
                                Text("Rimuru is thinking...").font(.custom("Poppins-Light", size: 12)).foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation { proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom) }
                }
            }
            .background(Color(hex: "#060C1A")) // Deeper navy for contrast
            
            // --- INPUT AREA ---
            VStack {
                Divider().background(Color.white.opacity(0.1))
                HStack(spacing: 12) {
                    TextField("Command Rimuru...", text: $inputText)
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .focused($isFocused)
                    
                    Button {
                        let text = inputText
                        inputText = ""
                        Task { await viewModel.processInput(text) }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 5)
                    }
                    .disabled(inputText.isEmpty || viewModel.isTyping)
                }
                .padding()
            }
            .background(.ultraThinMaterial)
        }
        .preferredColorScheme(.dark)
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .font(.custom("Poppins-Regular", size: 14))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isUser ?
                    LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundColor(.white)
                .cornerRadius(20, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                )
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

// Helper for specific rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
