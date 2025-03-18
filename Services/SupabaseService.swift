import Foundation
import Combine
import Supabase

// MARK: - Supabase Client

class SupabaseClient {
    static let shared = SupabaseClient()
    
    private let client: SupabaseClient
    
    private init() {
        // Initialize Supabase client with configuration
        self.client = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseURL)!,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Task {
                do {
                    let authResponse = try await self.client.auth.signIn(
                        email: email,
                        password: password
                    )
                    promise(.success(authResponse.user))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Task {
                do {
                    let authResponse = try await self.client.auth.signUp(
                        email: email,
                        password: password
                    )
                    promise(.success(authResponse.user))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Task {
                do {
                    try await self.client.auth.signOut()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getCurrentUser() -> AnyPublisher<User?, Error> {
        return Future<User?, Error> { promise in
            Task {
                do {
                    let session = try await self.client.auth.session
                    promise(.success(session.user))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Therapy Sessions
    
    func saveTherapySession(userId: String, data: [String: Any]) -> AnyPublisher<TherapySession, Error> {
        return Future<TherapySession, Error> { promise in
            Task {
                do {
                    var requestData = data
                    requestData["user_id"] = userId
                    
                    let response = try await self.client
                        .database
                        .from("therapy_sessions")
                        .insert(values: requestData)
                        .select()
                        .single()
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let session = try decoder.decode(TherapySession.self, from: response.data)
                    
                    promise(.success(session))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getTherapySessions(userId: String) -> AnyPublisher<[TherapySession], Error> {
        return Future<[TherapySession], Error> { promise in
            Task {
                do {
                    let response = try await self.client
                        .database
                        .from("therapy_sessions")
                        .select()
                        .eq(column: "user_id", value: userId)
                        .order(column: "created_at", ascending: false)
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let sessions = try decoder.decode([TherapySession].self, from: response.data)
                    
                    promise(.success(sessions))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getTherapySession(sessionId: String) -> AnyPublisher<TherapySession, Error> {
        return Future<TherapySession, Error> { promise in
            Task {
                do {
                    let response = try await self.client
                        .database
                        .from("therapy_sessions")
                        .select()
                        .eq(column: "id", value: sessionId)
                        .single()
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let session = try decoder.decode(TherapySession.self, from: response.data)
                    
                    promise(.success(session))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Session Messages
    
    func saveSessionMessage(sessionId: String, message: [String: Any]) -> AnyPublisher<Message, Error> {
        return Future<Message, Error> { promise in
            Task {
                do {
                    var requestData = message
                    requestData["session_id"] = sessionId
                    
                    let response = try await self.client
                        .database
                        .from("session_messages")
                        .insert(values: requestData)
                        .select()
                        .single()
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let message = try decoder.decode(Message.self, from: response.data)
                    
                    promise(.success(message))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getSessionMessages(sessionId: String) -> AnyPublisher<[Message], Error> {
        return Future<[Message], Error> { promise in
            Task {
                do {
                    let response = try await self.client
                        .database
                        .from("session_messages")
                        .select()
                        .eq(column: "session_id", value: sessionId)
                        .order(column: "created_at", ascending: true)
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let messages = try decoder.decode([Message].self, from: response.data)
                    
                    promise(.success(messages))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Journal Entries
    
    func saveJournalEntry(userId: String, data: [String: Any]) -> AnyPublisher<JournalEntry, Error> {
        return Future<JournalEntry, Error> { promise in
            Task {
                do {
                    var requestData = data
                    requestData["user_id"] = userId
                    
                    let response = try await self.client
                        .database
                        .from("journal_entries")
                        .insert(values: requestData)
                        .select()
                        .single()
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let entry = try decoder.decode(JournalEntry.self, from: response.data)
                    
                    promise(.success(entry))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getJournalEntries(userId: String) -> AnyPublisher<[JournalEntry], Error> {
        return Future<[JournalEntry], Error> { promise in
            Task {
                do {
                    let response = try await self.client
                        .database
                        .from("journal_entries")
                        .select()
                        .eq(column: "user_id", value: userId)
                        .order(column: "created_at", ascending: false)
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let entries = try decoder.decode([JournalEntry].self, from: response.data)
                    
                    promise(.success(entries))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Emotional Wellness
    
    func saveEmotionalEntry(userId: String, data: [String: Any]) -> AnyPublisher<EmotionalEntry, Error> {
        return Future<EmotionalEntry, Error> { promise in
            Task {
                do {
                    var requestData = data
                    requestData["user_id"] = userId
                    
                    let response = try await self.client
                        .database
                        .from("emotional_entries")
                        .insert(values: requestData)
                        .select()
                        .single()
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let entry = try decoder.decode(EmotionalEntry.self, from: response.data)
                    
                    promise(.success(entry))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getEmotionalEntries(userId: String, startDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<[EmotionalEntry], Error> {
        return Future<[EmotionalEntry], Error> { promise in
            Task {
                do {
                    var query = self.client
                        .database
                        .from("emotional_entries")
                        .select()
                        .eq(column: "user_id", value: userId)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    if let startDate = startDate {
                        let startDateString = dateFormatter.string(from: startDate)
                        query = query.gte(column: "date", value: startDateString)
                    }
                    
                    if let endDate = endDate {
                        let endDateString = dateFormatter.string(from: endDate)
                        query = query.lte(column: "date", value: endDateString)
                    }
                    
                    let response = try await query
                        .order(column: "date", ascending: false)
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let entries = try decoder.decode([EmotionalEntry].self, from: response.data)
                    
                    promise(.success(entries))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - User Profile
    
    func getUserProfile(userId: String) -> AnyPublisher<UserProfile, Error> {
        return Future<UserProfile, Error> { promise in
            Task {
                do {
                    let response = try await self.client
                        .database
                        .from("profiles")
                        .select()
                        .eq(column: "id", value: userId)
                        .single()
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let profile = try decoder.decode(UserProfile.self, from: response.data)
                    
                    promise(.success(profile))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateUserProfile(userId: String, data: [String: Any]) -> AnyPublisher<UserProfile, Error> {
        return Future<UserProfile, Error> { promise in
            Task {
                do {
                    let response = try await self.client
                        .database
                        .from("profiles")
                        .update(values: data)
                        .eq(column: "id", value: userId)
                        .select()
                        .single()
                        .execute()
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let profile = try decoder.decode(UserProfile.self, from: response.data)
                    
                    promise(.success(profile))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Models

struct User: Decodable {
    let id: String
    let email: String?
    let phone: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phone
        case createdAt = "created_at"
    }
}

struct TherapySession: Codable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    let title: String?
    let summary: String?
    let duration: Int?
    let moodBefore: Int?
    let moodAfter: Int?
    let therapistNotes: String?
    let topics: [String]?
    let therapyApproaches: [String]?
}

struct JournalEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    let title: String?
    let content: String?
    let mood: Int?
    let tags: [String]?
    let aiInsights: String?
}

struct EmotionalEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let date: Date
    let anxietyLevel: Int?
    let depressionLevel: Int?
    let stressLevel: Int?
    let sleepQuality: Int?
    let overallMood: Int?
    let notes: String?
    let contributingFactors: [String]?
}

struct UserProfile: Codable, Identifiable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let fullName: String?
    let avatarUrl: String?
    let therapyGoals: [String]?
    let therapyPreferences: [String: Any]?
    let emergencyContact: [String: Any]?
    
    // Custom coding keys to handle the JSON objects
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case therapyGoals = "therapy_goals"
        case therapyPreferences = "therapy_preferences"
        case emergencyContact = "emergency_contact"
    }
    
    // Custom decoder to handle JSON objects
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        therapyGoals = try container.decodeIfPresent([String].self, forKey: .therapyGoals)
        
        // Handle JSON objects
        if let preferencesData = try container.decodeIfPresent(Data.self, forKey: .therapyPreferences),
           let preferencesDict = try JSONSerialization.jsonObject(with: preferencesData, options: []) as? [String: Any] {
            therapyPreferences = preferencesDict
        } else {
            therapyPreferences = nil
        }
        
        if let contactData = try container.decodeIfPresent(Data.self, forKey: .emergencyContact),
           let contactDict = try JSONSerialization.jsonObject(with: contactData, options: []) as? [String: Any] {
            emergencyContact = contactDict
        } else {
            emergencyContact = nil
        }
    }
    
    // Custom encoder to handle JSON objects
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(fullName, forKey: .fullName)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try container.encodeIfPresent(therapyGoals, forKey: .therapyGoals)
        
        // Handle JSON objects
        if let preferences = therapyPreferences,
           let preferencesData = try? JSONSerialization.data(withJSONObject: preferences, options: []) {
            try container.encode(preferencesData, forKey: .therapyPreferences)
        }
        
        if let contact = emergencyContact,
           let contactData = try? JSONSerialization.data(withJSONObject: contact, options: []) {
            try container.encode(contactData, forKey: .emergencyContact)
        }
    }
}