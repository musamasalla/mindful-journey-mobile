import Foundation
import Combine

enum TrendDirection {
    case up
    case down
    case neutral
}

struct EmotionalEntry: Identifiable, Codable {
    let id: String
    let date: Date
    let moodScore: Int
    let anxietyLevel: Int
    let sleepQuality: Int
    let energyLevel: Int
    let notes: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        }
        
        return formatter.string(from: date)
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let mood: Double
    let anxiety: Double
    let sleep: Double
    let energy: Double
}

class EmotionalWellnessViewModel: ObservableObject {
    @Published var entries: [EmotionalEntry] = []
    @Published var chartData: [ChartDataPoint] = []
    
    // Average metrics
    @Published var averageMood: Double = 0.0
    @Published var averageAnxiety: Double = 0.0
    @Published var averageSleep: Double = 0.0
    @Published var averageEnergy: Double = 0.0
    
    // Trend directions
    @Published var moodTrend: TrendDirection = .neutral
    @Published var anxietyTrend: TrendDirection = .neutral
    @Published var sleepTrend: TrendDirection = .neutral
    @Published var energyTrend: TrendDirection = .neutral
    
    // AI-generated insight
    @Published var aiInsight: String = "Based on your entries, your mood tends to improve after a good night's sleep. Consider maintaining a consistent sleep schedule to help stabilize your mood."
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
        calculateAverages()
        calculateTrends()
        prepareChartData()
    }
    
    func addEntry(_ entry: EmotionalEntry) {
        entries.append(entry)
        calculateAverages()
        calculateTrends()
        prepareChartData()
        generateAIInsight()
        
        // In a real app, save to database or UserDefaults
        saveEntries()
    }
    
    func deleteEntry(_ entry: EmotionalEntry) {
        entries.removeAll { $0.id == entry.id }
        calculateAverages()
        calculateTrends()
        prepareChartData()
        generateAIInsight()
        
        // In a real app, update database or UserDefaults
        saveEntries()
    }
    
    private func calculateAverages() {
        guard !entries.isEmpty else {
            averageMood = 0
            averageAnxiety = 0
            averageSleep = 0
            averageEnergy = 0
            return
        }
        
        let moodSum = entries.reduce(0) { $0 + $1.moodScore }
        let anxietySum = entries.reduce(0) { $0 + $1.anxietyLevel }
        let sleepSum = entries.reduce(0) { $0 + $1.sleepQuality }
        let energySum = entries.reduce(0) { $0 + $1.energyLevel }
        
        let count = Double(entries.count)
        
        averageMood = Double(moodSum) / count
        averageAnxiety = Double(anxietySum) / count
        averageSleep = Double(sleepSum) / count
        averageEnergy = Double(energySum) / count
    }
    
    private func calculateTrends() {
        guard entries.count >= 2 else {
            moodTrend = .neutral
            anxietyTrend = .neutral
            sleepTrend = .neutral
            energyTrend = .neutral
            return
        }
        
        // Sort entries by date
        let sortedEntries = entries.sorted { $0.date < $1.date }
        
        // Get oldest and newest entries for comparison
        guard let oldestEntry = sortedEntries.first, let newestEntry = sortedEntries.last else {
            return
        }
        
        // Calculate trends (for anxiety, down is positive)
        moodTrend = calculateTrendDirection(oldValue: oldestEntry.moodScore, newValue: newestEntry.moodScore)
        anxietyTrend = calculateTrendDirection(oldValue: oldestEntry.anxietyLevel, newValue: newestEntry.anxietyLevel, isReversed: true)
        sleepTrend = calculateTrendDirection(oldValue: oldestEntry.sleepQuality, newValue: newestEntry.sleepQuality)
        energyTrend = calculateTrendDirection(oldValue: oldestEntry.energyLevel, newValue: newestEntry.energyLevel)
    }
    
    private func calculateTrendDirection(oldValue: Int, newValue: Int, isReversed: Bool = false) -> TrendDirection {
        let diff = newValue - oldValue
        
        if diff == 0 {
            return .neutral
        }
        
        if isReversed {
            return diff < 0 ? .up : .down
        } else {
            return diff > 0 ? .up : .down
        }
    }
    
    private func prepareChartData() {
        // Get the last 7 days of data or less if fewer entries exist
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var chartPoints: [ChartDataPoint] = []
        
        // Create data points for the last 7 days
        for dayOffset in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            // Calculate averages for the day or use 0 if no entries
            let dayMood = dayEntries.isEmpty ? 0 : Double(dayEntries.reduce(0) { $0 + $1.moodScore }) / Double(dayEntries.count)
            let dayAnxiety = dayEntries.isEmpty ? 0 : Double(dayEntries.reduce(0) { $0 + $1.anxietyLevel }) / Double(dayEntries.count)
            let daySleep = dayEntries.isEmpty ? 0 : Double(dayEntries.reduce(0) { $0 + $1.sleepQuality }) / Double(dayEntries.count)
            let dayEnergy = dayEntries.isEmpty ? 0 : Double(dayEntries.reduce(0) { $0 + $1.energyLevel }) / Double(dayEntries.count)
            
            // Format day label
            let dayLabel: String
            if dayOffset == 0 {
                dayLabel = "Today"
            } else if dayOffset == 1 {
                dayLabel = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                dayLabel = formatter.string(from: date)
            }
            
            let dataPoint = ChartDataPoint(
                date: date,
                dayLabel: dayLabel,
                mood: dayMood,
                anxiety: dayAnxiety,
                sleep: daySleep,
                energy: dayEnergy
            )
            
            chartPoints.append(dataPoint)
        }
        
        chartData = chartPoints
    }
    
    private func generateAIInsight() {
        // In a real app, this would call an API to generate personalized insights
        // For this demo, we'll use predefined insights based on the data
        
        if entries.isEmpty {
            aiInsight = "Start tracking your emotional wellness daily to receive personalized insights."
            return
        }
        
        // Check if mood correlates with sleep quality
        let highSleepEntries = entries.filter { $0.sleepQuality >= 7 }
        let lowSleepEntries = entries.filter { $0.sleepQuality <= 4 }
        
        let highSleepMoodAvg = highSleepEntries.isEmpty ? 0 : Double(highSleepEntries.reduce(0) { $0 + $1.moodScore }) / Double(highSleepEntries.count)
        let lowSleepMoodAvg = lowSleepEntries.isEmpty ? 0 : Double(lowSleepEntries.reduce(0) { $0 + $1.moodScore }) / Double(lowSleepEntries.count)
        
        if highSleepMoodAvg > lowSleepMoodAvg && !highSleepEntries.isEmpty && !lowSleepEntries.isEmpty {
            aiInsight = "Your mood tends to be \(String(format: "%.1f", highSleepMoodAvg - lowSleepMoodAvg)) points higher on days with good sleep quality. Consider prioritizing your sleep routine to help stabilize your mood."
            return
        }
        
        // Check if anxiety levels are improving
        if anxietyTrend == .up {
            aiInsight = "Your anxiety levels have been decreasing recently. Continue with the strategies that seem to be working for you, such as any relaxation techniques you may be practicing."
            return
        } else if anxietyTrend == .down {
            aiInsight = "Your anxiety levels have been increasing. Consider scheduling a therapy session to discuss effective coping strategies, and try incorporating more mindfulness practices into your daily routine."
            return
        }
        
        // Check for patterns in energy levels
        if energyTrend == .up {
            aiInsight = "Your energy levels have been improving. Notice what activities or lifestyle changes might be contributing to this positive trend and consider how to maintain them."
            return
        } else if energyTrend == .down {
            aiInsight = "Your energy levels have been decreasing. Consider evaluating your sleep patterns, physical activity, and nutrition, as these factors can significantly impact energy levels."
            return
        }
        
        // Default insight
        aiInsight = "Based on your tracking patterns, consistent monitoring of your emotional wellness can help identify personal triggers and effective coping strategies. Keep up the good work!"
    }
    
    // MARK: - Data Persistence (Mock)
    
    private func saveEntries() {
        // In a real app, save to UserDefaults or a database
        // For this demo, we'll just print a message
        print("Saved \(entries.count) entries")
    }
    
    private func loadMockData() {
        // Mock data for demonstration
        let calendar = Calendar.current
        let today = Date()
        
        let mockEntries: [EmotionalEntry] = [
            EmotionalEntry(
                id: "1",
                date: calendar.date(byAdding: .day, value: -6, to: today)!,
                moodScore: 4,
                anxietyLevel: 7,
                sleepQuality: 3,
                energyLevel: 4,
                notes: "Feeling quite anxious today. Work deadlines are piling up."
            ),
            EmotionalEntry(
                id: "2",
                date: calendar.date(byAdding: .day, value: -5, to: today)!,
                moodScore: 5,
                anxietyLevel: 6,
                sleepQuality: 5,
                energyLevel: 5,
                notes: "Slightly better today. Used breathing techniques when feeling overwhelmed."
            ),
            EmotionalEntry(
                id: "3",
                date: calendar.date(byAdding: .day, value: -4, to: today)!,
                moodScore: 6,
                anxietyLevel: 5,
                sleepQuality: 6,
                energyLevel: 6,
                notes: "Had a good therapy session which helped put things in perspective."
            ),
            EmotionalEntry(
                id: "4",
                date: calendar.date(byAdding: .day, value: -3, to: today)!,
                moodScore: 7,
                anxietyLevel: 4,
                sleepQuality: 7,
                energyLevel: 7,
                notes: "Feeling much more positive. Went for a walk which boosted my mood."
            ),
            EmotionalEntry(
                id: "5",
                date: calendar.date(byAdding: .day, value: -2, to: today)!,
                moodScore: 7,
                anxietyLevel: 4,
                sleepQuality: 8,
                energyLevel: 7,
                notes: "Another good day. Sleep has improved significantly."
            ),
            EmotionalEntry(
                id: "6",
                date: calendar.date(byAdding: .day, value: -1, to: today)!,
                moodScore: 6,
                anxietyLevel: 5,
                sleepQuality: 6,
                energyLevel: 6,
                notes: "A bit of a setback today but using techniques from therapy to cope."
            )
        ]
        
        entries = mockEntries
    }
}