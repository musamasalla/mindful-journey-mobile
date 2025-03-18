import Foundation
import Combine

// MARK: - Models

struct Message: Codable, Identifiable {
    var id: String // Supabase ID or client-generated ID
    var role: MessageRole
    var content: String
    var createdAt: Date
    var isVoice: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case content
        case createdAt = "created_at"
        case isVoice = "is_voice"
    }
}

enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
    let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Decodable {
    let id: String
    let choices: [Choice]
    let usage: Usage
    
    struct Choice: Decodable {
        let message: ChatMessage
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

// MARK: - Service Implementation

class OpenAIService {
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func sendChat(messages: [Message], temperature: Double = 0.7, maxTokens: Int? = nil) -> AnyPublisher<String, Error> {
        // Convert our Message model to ChatMessage
        let chatMessages = messages.map { ChatMessage(role: $0.role.rawValue, content: $0.content) }
        
        let requestBody = ChatCompletionRequest(
            model: AppConfig.openAIModel,
            messages: chatMessages,
            temperature: temperature,
            maxTokens: maxTokens
        )
        
        // Create the URL request
        guard let url = URL(string: baseURL) else {
            return Fail(error: NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(AppConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the request body
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // Set timeout
        request.timeoutInterval = AppConfig.apiTimeout
        
        // Send the request
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                // Verify HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
                }
                
                // Check for valid status code
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)",
                        "responseData": String(data: data, encoding: .utf8) ?? "No data"
                    ])
                }
                
                return data
            }
            .decode(type: ChatCompletionResponse.self, decoder: JSONDecoder())
            .map { response in
                // Extract the response text
                if let firstChoice = response.choices.first {
                    return firstChoice.message.content
                } else {
                    return "No response generated."
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Simplified function for easier use
    func generateResponse(from messages: [Message]) -> AnyPublisher<String, Error> {
        return sendChat(messages: messages)
    }
}

// MARK: - Mock Service for Preview and Testing

class MockOpenAIService: OpenAIService {
    override func generateResponse(from messages: [Message]) -> AnyPublisher<String, Error> {
        // Simulate network delay
        return Just("This is a simulated AI response for testing purposes. In a real environment, this would be a thoughtful, empathetic response tailored to the user's message.")
            .delay(for: .seconds(1.5), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}