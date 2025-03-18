import Foundation

// IMPORTANT: Rename this file to Config.swift and fill in your actual API keys
// Make sure Config.swift is added to .gitignore to keep your keys secure

struct AppConfig {
    // Supabase configuration
    static let supabaseURL = "https://your-supabase-project-url.supabase.co"
    static let supabaseAnonKey = "your-supabase-anon-key"
    
    // OpenAI configuration
    static let openAIAPIKey = "your-openai-api-key"
    static let openAIModel = "gpt-4" // or your preferred model
    
    // Voice synthesis configuration (optional)
    static let useVoiceFeatures = true
    static let voiceAPIKey = "your-voice-api-key" // if using a third-party service
    
    // Application settings
    static let apiTimeout: TimeInterval = 30.0
    static let maxSessionHistoryItems = 100
    static let defaultSystemPrompt = """
    You are an empathetic AI therapist trained in cognitive behavioral therapy, dialectical behavior therapy, acceptance and commitment therapy, and mindfulness practices. 
    
    Your approach is compassionate, supportive, and professional. You help users explore their thoughts, feelings, and behaviors while offering evidence-based guidance and reflections.
    
    Always prioritize user safety. If a user expresses thoughts of self-harm or harming others, direct them to appropriate crisis resources.
    
    Maintain appropriate therapeutic boundaries. You are not a replacement for professional mental health treatment but a supportive companion for emotional wellness.
    
    In your responses:
    - Use a warm, empathetic tone
    - Practice active listening through thoughtful questions and reflections
    - Offer therapeutic techniques relevant to the user's concerns
    - Keep responses concise and focused
    - Encourage healthy coping strategies
    - Validate the user's experiences and emotions
    
    Your goal is to support the user's mental health journey through thoughtful dialogue and evidence-based approaches.
    """
    
    // Crisis resources
    static let crisisResources = [
        CrisisResource(
            name: "988 Suicide & Crisis Lifeline",
            description: "24/7 support for people in distress",
            contactInfo: "Call or text 988",
            url: "https://988lifeline.org/"
        ),
        CrisisResource(
            name: "Crisis Text Line",
            description: "24/7 text-based crisis support",
            contactInfo: "Text HOME to 741741",
            url: "https://www.crisistextline.org/"
        ),
        CrisisResource(
            name: "National Alliance on Mental Illness (NAMI)",
            description: "Information and resources for mental health",
            contactInfo: "Call 1-800-950-NAMI (6264)",
            url: "https://www.nami.org/"
        )
    ]
}

// Supporting structures
struct CrisisResource {
    let name: String
    let description: String
    let contactInfo: String
    let url: String
}