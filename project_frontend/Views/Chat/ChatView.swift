import SwiftUI

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
    
    var attributedContent: AttributedString {
        if isUser {
            return AttributedString(content)
        } else {
            do {
                // 创建 AttributedString 的选项
                var options = AttributedString.MarkdownParsingOptions()
                options.interpretedSyntax = .inlineOnlyPreservingWhitespace
                
                // 将换行符转换为实际的换行
                let processedContent = content.replacingOccurrences(of: "\\n", with: "\n")
                return try AttributedString(markdown: processedContent, options: options)
            } catch {
                return AttributedString(content)
            }
        }
    }
}

struct ChatView: View {
    @AppStorage("chat_messages") private var savedMessages: Data = Data()
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var chatHistory: [APIService.ChatMessage] = [
        .init(role: "user", parts: "Hello"),
        .init(role: "model", parts: "Great to meet you. I am your Food genie. What would you like to know?")
    ]
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    @AppStorage("user_id") private var userId: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            if isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        scrollProxy = proxy
                        // 加载保存的消息
                        if let decodedMessages = try? JSONDecoder().decode([Message].self, from: savedMessages) {
                            messages = decodedMessages
                        } else if messages.isEmpty {
                            // 如果没有保存的消息，显示初始消息
                            messages.append(Message(content: chatHistory[0].parts, isUser: true, timestamp: Date()))
                            messages.append(Message(content: chatHistory[1].parts, isUser: false, timestamp: Date()))
                        }
                        // Scroll to bottom after a short delay to ensure messages are rendered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scrollToBottom()
                        }
                    }
                }
                
                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    .padding(.trailing)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .shadow(radius: 1)
            }
            .navigationTitle("Food Genie😊")
        }
    }
    
    private func scrollToBottom() {
        guard let lastMessage = messages.last else { return }
        withAnimation {
            scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    private func sendMessage() {
        let messageText = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        let userMessage = Message(content: messageText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        newMessage = ""
        isLoading = true
        
        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollToBottom()
        }
        
        Task {
            do {
                let updatedHistory = try await APIService.sendChatMessage(
                    userId: String(userId),
                    message: messageText,
                    history: chatHistory
                )
                
                // Update chat history
                chatHistory = updatedHistory
                
                // Add AI response to messages
                if let lastMessage = updatedHistory.last {
                    DispatchQueue.main.async {
                        let aiMessage = Message(
                            content: lastMessage.parts,
                            isUser: false,
                            timestamp: Date()
                        )
                        messages.append(aiMessage)
                        isLoading = false
                        
                        // 保存消息
                        if let encodedMessages = try? JSONEncoder().encode(messages) {
                            savedMessages = encodedMessages
                        }
                        
                        // 滚动到底部
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scrollToBottom()
                        }
                    }
                }
            } catch {
                print("Chat error: \(error)")
                DispatchQueue.main.async {
                    let errorMessage = Message(
                        content: "Sorry, I encountered an error. Please try again.",
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(errorMessage)
                    isLoading = false
                    
                    // 滚动到底部
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom()
                    }
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.attributedContent)
                .padding(12)
                .background(message.isUser ? AppTheme.primary : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true) // 允许文本垂直扩展
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading) // 限制最大宽度
            
            if !message.isUser { Spacer() }
        }
    }
}

#Preview {
    ChatView()
}
