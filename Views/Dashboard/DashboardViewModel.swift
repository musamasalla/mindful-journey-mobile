import Foundation
import SwiftUI
import Combine

struct TherapyGoal: Identifiable {
    let id: String
    let title: String
    let progress: Int
}

struct UpcomingActivity: Identifiable {
    let id: String
    let title: String
    let time: Date
    let type: ActivityType
    let iconName: String
    let color: Color
    
    enum ActivityType {
        case therapySession
        case journalPrompt
        case emotionalCheck
        case mindfulnessPractice
    }
    
    var timeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: time, relativeTo: Date())
    }
}

class DashboardViewModel: ObservableObject {
    // Emotional wellness metrics
    @Published var moodScore: Int = 7
    @Published var anxietyLevel: Int = 4
    @Published var moodTrendData: [Int] = [4, 5, 6, 7, 7, 6, 7]
    
    // Progress statistics
    @Published var sessionsCompleted: Int = 8
    @Published var journalEntries: Int = 15
    @Published var currentStreak: Int = 5
    
    // Therapy goals
    @Published var therapyGoals: [TherapyGoal] = []
    
    // Upcoming activities
    @Published var upcomingActivities: [UpcomingActivity] = []
    
    // AI insights
    @Published var aiInsight: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        // Set up mock goals
        therapyGoals = [
            TherapyGoal(
                id: "goal1",
                title: "Reduce workplace anxiety",
                progress: 65
            ),
            TherapyGoal(
                id: "goal2",
                title: "Improve sleep quality",
                progress: 40
            ),
            TherapyGoal(
                id: "goal3",
                title: "Develop mindfulness practice",
                progress: 80
            )
        ]
        
        // Set up mock upcoming activities
        upcomingActivities = [
            UpcomingActivity(
                id: "act1",
                title: "Scheduled Therapy Session",
                time: Date().addingTimeInterval(3600 * 24), // Tomorrow
                type: .therapySession,
                iconName: "bubble.left.fill",
                color: .blue
            ),
            UpcomingActivity(
                id: "act2",
                title: "Mindfulness Exercise",
                time: Date().addingTimeInterval(3600 * 2), // 2 hours from now
                type: .mindfulnessPractice,
                iconName: "heart.fill",
                color: .purple
            ),
            UpcomingActivity(
                id: "act3",
                title: "Mood Check-in Reminder",
                time: Date().addingTimeInterval(3600 * 6), // 6 hours from now
                type: .emotionalCheck,
                iconName: "chart.bar.fill",
                color: .orange
            )
        ]
        
        // Set up mock AI insight
        aiInsight = "I've noticed your mood improves after journaling about work concerns. Your anxiety has decreased by 30% over the past week, which correlates with your consistent mindfulness practice. Consider scheduling your mindfulness exercises for the morning to maintain this positive trend throughout the day."
    }
    
    // MARK: - Data Loading (would be implemented in a real app)
    
    func loadUserData() {
        // In a real app, this would fetch user data from a local database or API
        print("Loading user data...")
    }
    
    func loadWellnessData() {
        // In a real app, this would fetch wellness tracking data from a local database or API
        print("Loading wellness data...")
    }
    
    func loadGoalsData() {
        // In a real app, this would fetch therapy goals from a local database or API
        print("Loading goals data...")
    }
    
    func loadUpcomingActivities() {
        // In a real app, this would fetch upcoming activities from a local database or API
        print("Loading upcoming activities...")
    }
    
    func generateAIInsight() {
        // In a real app, this would either call an API to generate insights
        // or use local logic to analyze user data and generate insights
        print("Generating AI insights...")
    }
    
    // MARK: - Action Handlers (would be implemented in a real app)
    
    func startTherapySession() {
        // In a real app, this would initiate a new therapy session
        print("Starting therapy session...")
    }
    
    func createJournalEntry() {
        // In a real app, this would navigate to create a new journal entry
        print("Creating journal entry...")
    }
    
    func trackEmotionalWellness() {
        // In a real app, this would navigate to emotional wellness tracking
        print("Tracking emotional wellness...")
    }
    
    func updateTherapyGoal(_ goalId: String, progress: Int) {
        // In a real app, this would update a therapy goal's progress
        if let index = therapyGoals.firstIndex(where: { $0.id == goalId }) {
            therapyGoals[index] = TherapyGoal(
                id: goalId, 
                title: therapyGoals[index].title, 
                progress: progress
            )
        }
    }
    
    func completeActivity(_ activityId: String) {
        // In a real app, this would mark an activity as completed
        upcomingActivities.removeAll { $0.id == activityId }
    }
    
    // MARK: - User Statistics (would be implemented in a real app)
    
    func calculateStreak() -> Int {
        // In a real app, this would calculate the current streak based on user activity
        return currentStreak
    }
    
    func calculateTotalMinutesInTherapy() -> Int {
        // In a real app, this would calculate total minutes spent in therapy sessions
        return sessionsCompleted * 30 // Assuming 30 minutes per session
    }
    
    func calculateAverageMood(forDays days: Int) -> Double {
        // In a real app, this would calculate the average mood score for a given period
        let sum = moodTrendData.suffix(days).reduce(0, +)
        return Double(sum) / Double(min(days, moodTrendData.count))
    }
}