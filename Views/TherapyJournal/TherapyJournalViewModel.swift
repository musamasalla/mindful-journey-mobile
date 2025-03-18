import Foundation
import Combine

struct JournalEntry: Identifiable, Codable {
    let id: String
    let date: Date
    let title: String
    let content: String
    let tags: [String]
    let aiReflection: String
    
    static func mockEntries() -> [JournalEntry] {
        return [
            JournalEntry(
                id: "1",
                date: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                title: "Processing therapy insights",
                content: "Today's therapy session was really insightful. We discussed how my anxiety about work deadlines might be connected to my perfectionism. I realized I've been setting unrealistic standards for myself, which has been making me feel constantly inadequate. My therapist suggested I try to recognize when I'm being too hard on myself and practice replacing critical thoughts with more compassionate ones. I'm going to try focusing on what I've accomplished each day rather than what I didn't get to.",
                tags: ["therapy", "anxiety", "work", "insights"],
                aiReflection: "Great insight about the connection between perfectionism and anxiety. Recognizing unrealistic standards is an important step. Try the self-compassion exercises we discussed when you notice self-criticism. What small achievement can you celebrate today?"
            ),
            JournalEntry(
                id: "2",
                date: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                title: "Difficult conversation with manager",
                content: "Had to talk with my manager today about feeling overwhelmed with my current workload. I was really nervous about it, but it went better than expected. She was understanding and we worked out a plan to redistribute some tasks. I'm still feeling a bit anxious about whether this will affect how she sees my capabilities, but also relieved to have spoken up. Using the assertiveness techniques from therapy helped - I stated my needs clearly without apologizing unnecessarily.",
                tags: ["work", "communication", "anxiety", "boundaries"],
                aiReflection: "You demonstrated excellent boundary-setting and assertiveness! It's normal to worry about others' perceptions after setting boundaries. Remember that healthy workplace relationships involve open communication about capacity. Notice how the relief you felt confirms you made the right choice."
            ),
            JournalEntry(
                id: "3",
                date: Date().addingTimeInterval(-86400 * 1), // 1 day ago
                title: "Progress with mindfulness practice",
                content: "I've been trying the 5-minute mindfulness meditation each morning for a week now. At first it was really hard to focus, but it's getting a little easier to bring my attention back when it wanders. Today I noticed I felt calmer during my morning commute, which is usually when I start worrying about the day ahead. I'm proud of sticking with this practice even though it's challenging. The breathing technique from the therapy app has been particularly helpful when I notice my chest tightening with stress.",
                tags: ["mindfulness", "progress", "meditation", "proud"],
                aiReflection: "Wonderful progress with your mindfulness practice! Consistency is more important than perfection with meditation. The fact that you're noticing real-world benefits during your commute is significant - these tangible results will help reinforce your practice. Consider journaling about other subtle changes you notice throughout your day."
            )
        ]
    }
}

class TherapyJournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    init() {
        // Load mock data for demonstration
        loadEntries()
    }
    
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        
        // In a real app, save to persistent storage
        saveEntries()
    }
    
    func deleteEntry(id: String) {
        entries.removeAll { $0.id == id }
        
        // In a real app, update persistent storage
        saveEntries()
    }
    
    func updateEntry(_ updatedEntry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
            entries[index] = updatedEntry
            
            // In a real app, update persistent storage
            saveEntries()
        }
    }
    
    // MARK: - Persistence
    
    private func saveEntries() {
        // In a real app, this would save to UserDefaults or a database
        // For this demo, we'll just print a message
        print("Saved \(entries.count) journal entries")
    }
    
    private func loadEntries() {
        // In a real app, this would load from UserDefaults or a database
        // For this demo, we'll load mock data
        entries = JournalEntry.mockEntries()
    }
    
    // MARK: - Analytics and Insights
    
    func getEmotionKeywords() -> [String] {
        let emotionKeywords = [
            "happy", "sad", "angry", "anxious", "scared", "worried",
            "content", "stressed", "depressed", "excited", "frustrated",
            "overwhelmed", "peaceful", "hopeful", "hopeless", "joyful",
            "afraid", "grateful", "guilty", "lonely", "proud"
        ]
        
        var foundEmotions: [String] = []
        
        for entry in entries {
            let contentLowercase = entry.content.lowercased()
            for emotion in emotionKeywords {
                if contentLowercase.contains(emotion) && !foundEmotions.contains(emotion) {
                    foundEmotions.append(emotion)
                }
            }
        }
        
        return foundEmotions
    }
    
    func getMostFrequentTags(limit: Int = 5) -> [(tag: String, count: Int)] {
        var tagCounts: [String: Int] = [:]
        
        for entry in entries {
            for tag in entry.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        let sortedTags = tagCounts.sorted { $0.value > $1.value }
        return sortedTags.prefix(limit).map { (tag: $0.key, count: $0.value) }
    }
    
    func getJournalingSummary() -> String {
        guard !entries.isEmpty else {
            return "Start journaling to receive insights about your therapeutic journey."
        }
        
        let entryCount = entries.count
        let daysSinceFirstEntry = Calendar.current.dateComponents([.day], from: entries.map { $0.date }.min()!, to: Date()).day!
        let mostFrequentTags = getMostFrequentTags(limit: 3).map { $0.tag }.joined(separator: ", ")
        
        return "You've written \(entryCount) journal entries over the past \(daysSinceFirstEntry) days. Your most frequent topics include \(mostFrequentTags)."
    }
}