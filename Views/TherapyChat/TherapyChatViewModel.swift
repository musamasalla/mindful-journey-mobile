import Foundation
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let isUser: Bool
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

class TherapyChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTherapistTyping = false
    
    var sessionNumber: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // In a real app, this would be loaded from UserDefaults or a database
        self.sessionNumber = UserDefaults.standard.integer(forKey: "therapySessionCount") + 1
    }
    
    func startSession() {
        // Add initial greeting message from therapist
        let initialMessage = """
        Hello, I'm your AI therapist. I'm here to provide a safe space for you to discuss your thoughts, feelings, and challenges.
        
        How are you feeling today?
        """
        
        let systemMessage = ChatMessage(
            content: initialMessage,
            timestamp: Date(),
            isUser: false
        )
        
        messages.append(systemMessage)
    }
    
    func sendMessage(_ text: String) {
        // Add user message
        let userMessage = ChatMessage(
            content: text,
            timestamp: Date(),
            isUser: true
        )
        
        messages.append(userMessage)
        
        // Simulate AI therapist typing
        isTherapistTyping = true
        
        // In a real app, this would call an API to get a response
        // For demo purposes, we'll simulate a delay and then generate a response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let aiResponse = self.generateTherapistResponse(to: text)
            let aiMessage = ChatMessage(
                content: aiResponse,
                timestamp: Date(),
                isUser: false
            )
            
            self.messages.append(aiMessage)
            self.isTherapistTyping = false
            
            // In a real app, we would save the conversation history to a database
        }
    }
    
    private func generateTherapistResponse(to userMessage: String) -> String {
        // This is a simple response generator for demonstration purposes
        // In a real app, this would be replaced with an actual API call to a language model
        
        let lowercasedMessage = userMessage.lowercased()
        
        // Check for anxiety-related keywords
        if lowercasedMessage.contains("anxious") || lowercasedMessage.contains("anxiety") || lowercasedMessage.contains("worried") || lowercasedMessage.contains("stress") {
            return """
            It sounds like you're experiencing some anxiety. This is very common and there are effective ways to manage it.
            
            Can you tell me more about what situations trigger these feelings for you? And how does the anxiety manifest - physically, emotionally, or in your thoughts?
            
            Some people find deep breathing helpful in the moment. Would you like to try a quick breathing exercise together?
            """
        }
        
        // Check for depression-related keywords
        if lowercasedMessage.contains("sad") || lowercasedMessage.contains("depressed") || lowercasedMessage.contains("depression") || lowercasedMessage.contains("hopeless") || lowercasedMessage.contains("unmotivated") {
            return """
            I'm hearing that you're experiencing some feelings of sadness or low mood. Thank you for sharing that with me.
            
            How long have you been feeling this way? Have there been any changes in your life recently that might be contributing to these feelings?
            
            Remember that experiencing periods of sadness is part of being human, but if these feelings are persistent or interfering with your daily life, it might be helpful to discuss them with a healthcare provider.
            """
        }
        
        // Check for sleep-related issues
        if lowercasedMessage.contains("sleep") || lowercasedMessage.contains("insomnia") || lowercasedMessage.contains("tired") || lowercasedMessage.contains("exhausted") {
            return """
            Sleep difficulties can have a significant impact on our mental health and overall wellbeing.
            
            What has your sleep pattern been like recently? Are you having trouble falling asleep, staying asleep, or waking up too early?
            
            Many people find that establishing a regular sleep routine and practicing good sleep hygiene can be helpful. Would you like to discuss some strategies that might improve your sleep quality?
            """
        }
        
        // Check for relationship issues
        if lowercasedMessage.contains("relationship") || lowercasedMessage.contains("partner") || lowercasedMessage.contains("spouse") || lowercasedMessage.contains("boyfriend") || lowercasedMessage.contains("girlfriend") || lowercasedMessage.contains("marriage") {
            return """
            Relationships can bring great joy but also present challenges at times.
            
            Could you share more about what you're experiencing in this relationship? What aspects have been difficult for you?
            
            Understanding our patterns of communication and attachment can often help us navigate relationship difficulties. How do you typically express your needs and feelings in this relationship?
            """
        }
        
        // Check for work-related stress
        if lowercasedMessage.contains("work") || lowercasedMessage.contains("job") || lowercasedMessage.contains("career") || lowercasedMessage.contains("boss") || lowercasedMessage.contains("colleague") {
            return """
            Work-related stress is something many people experience. Finding a healthy work-life balance can be challenging.
            
            What aspects of your work situation are most stressful for you? And how has this been affecting other areas of your life?
            
            Setting boundaries and practicing self-care are important when dealing with workplace stress. Would you like to explore some strategies that might help you manage this better?
            """
        }
        
        // Check for positive emotions
        if lowercasedMessage.contains("happy") || lowercasedMessage.contains("good") || lowercasedMessage.contains("great") || lowercasedMessage.contains("wonderful") || lowercasedMessage.contains("better") {
            return """
            I'm glad to hear there are positive aspects to how you're feeling. It's important to acknowledge and celebrate these moments.
            
            What do you think has contributed to these positive feelings? Identifying the activities, people, or circumstances that enhance our wellbeing can help us intentionally incorporate more of them into our lives.
            
            Would you like to explore ways to build on these positive experiences?
            """
        }
        
        // Check for greeting
        if lowercasedMessage.contains("hello") || lowercasedMessage.contains("hi") || lowercasedMessage.contains("hey") || userMessage.count < 10 {
            return """
            Hello! I'm here to support you in your mental health journey. How can I help you today?
            
            We could talk about your current emotions, challenges you're facing, or specific areas of your life you'd like to work on. What's been on your mind recently?
            """
        }
        
        // Default response for other messages
        return """
        Thank you for sharing that with me. I appreciate your openness.
        
        Could you tell me more about how these experiences have been affecting you emotionally? Understanding the connection between our thoughts, feelings, and behaviors is often a helpful step in addressing our challenges.
        
        What would you like to focus on in our conversation today?
        """
    }
    
    func endSession() {
        // In a real app, this would save the session details to a database
        UserDefaults.standard.set(sessionNumber, forKey: "therapySessionCount")
    }
}