import SwiftUI

struct TherapyChatView: View {
    @StateObject private var viewModel = TherapyChatViewModel()
    @StateObject private var voiceManager = VoiceChatManager()
    @State private var messageText = ""
    @State private var showingCrisisResources = false
    @State private var showingSessionInfo = false
    @State private var isVoiceModeActive = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: {
                    showingSessionInfo.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AI Therapist")
                                .font(.headline)
                            Text("Session #\(viewModel.sessionNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading)
                
                Spacer()
                
                Button(action: {
                    showingCrisisResources.toggle()
                }) {
                    Image(systemName: "shield.checkered")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
            
            // Voice mode indicator
            if isVoiceModeActive {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.blue)
                    Text("Voice Mode Active")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Spacer()
                    
                    // Listening state indicator
                    if voiceManager.state == .listening {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("Listening...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else if voiceManager.state == .speaking {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Speaking...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
            }
            
            // Chat messages
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                                .onTapGesture {
                                    // Tap on AI message to have it read aloud
                                    if !message.isUser && isVoiceModeActive {
                                        voiceManager.speakText(message.content)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            scrollView.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            
                            // Auto-read latest AI message in voice mode
                            if isVoiceModeActive,
                               let lastMessage = viewModel.messages.last,
                               !lastMessage.isUser {
                                voiceManager.speakText(lastMessage.content)
                            }
                        }
                    }
                }
            }
            
            // Voice transcript (when listening)
            if voiceManager.state == .listening && !voiceManager.transcript.isEmpty {
                Text(voiceManager.transcript)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            
            // Input area
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    // Text input field
                    if !isVoiceModeActive {
                        TextField("Type a message...", text: $messageText, axis: .vertical)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .focused($isInputFocused)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // Voice button
                    Button(action: toggleVoiceMode) {
                        Image(systemName: isVoiceModeActive ? "keyboard" : "mic.fill")
                            .font(.system(size: 24))
                            .padding(8)
                            .background(isVoiceModeActive ? Color.blue : Color(.systemGray6))
                            .foregroundColor(isVoiceModeActive ? .white : .blue)
                            .clipShape(Circle())
                    }
                    
                    // Voice controls (only shown in voice mode)
                    if isVoiceModeActive {
                        Button(action: handleVoiceAction) {
                            Image(systemName: voiceButtonIcon)
                                .font(.system(size: 32))
                                .padding(12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .disabled(!voiceManager.isPermissionGranted)
                        
                        Button(action: sendVoiceMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(
                                    voiceManager.transcript.isEmpty ? .gray : .blue
                                )
                        }
                        .disabled(voiceManager.transcript.isEmpty)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingCrisisResources) {
            CrisisResourcesView()
        }
        .sheet(isPresented: $showingSessionInfo) {
            SessionInfoView(sessionNumber: viewModel.sessionNumber)
        }
        .alert(item: alertItem) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            voiceManager.stopAll()
        }
    }
    
    private var alertItem: AlertItem? {
        if let error = voiceManager.errorMessage {
            return AlertItem(
                id: UUID().uuidString,
                title: "Voice Mode Error",
                message: error
            )
        }
        return nil
    }
    
    private var voiceButtonIcon: String {
        switch voiceManager.state {
        case .idle:
            return "mic.fill"
        case .listening:
            return "mic.slash.fill"
        case .processing:
            return "arrow.clockwise"
        case .speaking:
            return "stop.fill"
        }
    }
    
    private func toggleVoiceMode() {
        isVoiceModeActive.toggle()
        voiceManager.stopAll()
        
        // If switching to voice mode and permissions not granted
        if isVoiceModeActive && !voiceManager.isPermissionGranted {
            // Show permission alert
        }
    }
    
    private func handleVoiceAction() {
        switch voiceManager.state {
        case .idle:
            voiceManager.startListening()
        case .listening:
            voiceManager.stopListening()
            // Transcript is saved but not sent yet
        case .speaking:
            voiceManager.stopSpeaking()
        case .processing:
            // Do nothing while processing
            break
        }
    }
    
    private func sendVoiceMessage() {
        guard !voiceManager.transcript.isEmpty else { return }
        
        // Send the transcript as a message
        viewModel.sendMessage(voiceManager.transcript)
        
        // Clear transcript and reset state
        voiceManager.transcript = ""
        voiceManager.state = .idle
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        viewModel.sendMessage(messageText)
        messageText = ""
        isInputFocused = false
    }
}

struct AlertItem: Identifiable {
    var id: String
    var title: String
    var message: String
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isUser ? Color.blue : Color(.systemGray6))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                
                Text(message.formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
}

struct CrisisResourcesView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("If you're experiencing a mental health crisis or having thoughts of harming yourself, please use these resources to get immediate help.")
                    .font(.body)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ResourceLink(
                        title: "988 Suicide & Crisis Lifeline",
                        description: "Call or text 988",
                        icon: "phone.fill"
                    )
                    
                    ResourceLink(
                        title: "Crisis Text Line",
                        description: "Text HOME to 741741",
                        icon: "message.fill"
                    )
                    
                    ResourceLink(
                        title: "Emergency Services",
                        description: "Call 911",
                        icon: "exclamationmark.triangle.fill"
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Text("This app is not a replacement for professional mental health treatment. If you're experiencing a mental health emergency, please seek help immediately.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Crisis Resources")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ResourceLink: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct SessionInfoView: View {
    let sessionNumber: Int
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // AI Therapist Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("About Your AI Therapist")
                        .font(.headline)
                    
                    Text("Your AI therapist is powered by advanced natural language processing and therapeutic approaches, designed to provide evidence-based mental health support. While not a replacement for human professionals, it offers a supportive space for reflection and growth.")
                        .font(.body)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Session Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Information")
                        .font(.headline)
                    
                    InfoRow(label: "Session Number", value: "#\(sessionNumber)")
                    InfoRow(label: "Duration", value: "Unlimited")
                    InfoRow(label: "Conversation", value: "Private & Secure")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Therapeutic Approaches
                VStack(alignment: .leading, spacing: 8) {
                    Text("Therapeutic Approaches")
                        .font(.headline)
                    
                    ForEach(therapeuticApproaches, id: \.self) { approach in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text(approach)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Voice Mode Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Voice Mode")
                        .font(.headline)
                    
                    Text("Voice mode allows you to speak directly with your AI therapist. Tap the microphone icon to toggle voice mode, then tap it again to start or stop recording. Tap on any therapist message to have it read aloud.")
                        .font(.body)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Disclaimer
                Text("This AI therapist is not a replacement for professional mental health treatment. In case of emergency, please contact a crisis helpline or seek immediate medical attention.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private let therapeuticApproaches = [
        "Cognitive Behavioral Therapy (CBT)",
        "Dialectical Behavior Therapy (DBT)",
        "Acceptance and Commitment Therapy (ACT)",
        "Mindfulness-Based Approaches",
        "Solution-Focused Brief Therapy"
    ]
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct TherapyChatView_Previews: PreviewProvider {
    static var previews: some View {
        TherapyChatView()
    }
}