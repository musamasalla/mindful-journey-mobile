import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    welcomeSection
                    
                    quickActionsSection
                    
                    emotionalWellnessSection
                    
                    therapyProgressSection
                    
                    upcomingActivitiesSection
                    
                    aiInsightsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Dashboard")
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome Back")
                .font(.largeTitle)
                .bold()
            
            Text("Continue your therapeutic journey")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.leading, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                NavigationLink(destination: TherapyChatView()) {
                    ActionCard(
                        title: "Therapy Session",
                        description: "Talk with your AI therapist",
                        systemImage: "message.fill",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: EmotionalWellnessView()) {
                    ActionCard(
                        title: "Track Wellness",
                        description: "Log today's emotional state",
                        systemImage: "chart.line.uptrend.xyaxis.circle.fill",
                        color: .green
                    )
                }
                
                NavigationLink(destination: TherapyJournalView()) {
                    ActionCard(
                        title: "Journal Entry",
                        description: "Record your thoughts",
                        systemImage: "book.fill",
                        color: .purple
                    )
                }
                
                NavigationLink(destination: EmptyView()) {
                    ActionCard(
                        title: "Set Goals",
                        description: "Plan your therapy journey",
                        systemImage: "target",
                        color: .orange
                    )
                }
            }
        }
    }
    
    // MARK: - Emotional Wellness Section
    private var emotionalWellnessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Emotional Wellness")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: EmotionalWellnessView()) {
                    Text("Details")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.leading, 4)
            
            HStack(spacing: 16) {
                EmotionMetricView(
                    value: viewModel.moodScore,
                    label: "Mood",
                    icon: "face.smiling.fill",
                    color: .blue
                )
                
                EmotionMetricView(
                    value: viewModel.anxietyLevel,
                    label: "Anxiety",
                    icon: "waveform.path.ecg.rectangle.fill",
                    color: .red
                )
            }
            
            WellnessTrendView(data: viewModel.moodTrendData)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Therapy Progress Section
    private var therapyProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Therapy Progress")
                .font(.headline)
                .padding(.leading, 4)
            
            HStack(spacing: 20) {
                StatCardView(
                    value: "\(viewModel.sessionsCompleted)",
                    label: "Sessions",
                    icon: "text.bubble.fill",
                    color: .blue
                )
                
                StatCardView(
                    value: "\(viewModel.journalEntries)",
                    label: "Journal Entries",
                    icon: "book.fill",
                    color: .purple
                )
                
                StatCardView(
                    value: "\(viewModel.currentStreak)",
                    label: "Day Streak",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            // Therapy goals
            VStack(alignment: .leading, spacing: 10) {
                Text("Goals Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(viewModel.therapyGoals) { goal in
                    GoalProgressView(goal: goal)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Upcoming Activities Section
    private var upcomingActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Activities")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    // Navigate to all activities
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.leading, 4)
            
            ForEach(viewModel.upcomingActivities) { activity in
                UpcomingActivityRow(activity: activity)
            }
        }
    }
    
    // MARK: - AI Insights Section
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("AI Therapist Insights")
                    .font(.headline)
            }
            .padding(.leading, 4)
            
            Text(viewModel.aiInsight)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Helper Views

struct ActionCard: View {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct EmotionMetricView: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("\(value)/10")
                .font(.system(size: 28, weight: .bold))
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(color)
                    .frame(width: (CGFloat(value) / 10) * UIScreen.main.bounds.width * 0.35, height: 8)
                    .cornerRadius(4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct WellnessTrendView: View {
    let data: [Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Mood Trend")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data.indices, id: \.self) { index in
                    VStack {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 30, height: CGFloat(data[index]) * 8)
                            .cornerRadius(4)
                        
                        Text(dayLabel(for: index))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func dayLabel(for index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
}

struct StatCardView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct GoalProgressView: View {
    let goal: TherapyGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(goal.progress)%")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(goal.progress > 75 ? Color.green : 
                          goal.progress > 40 ? Color.blue : Color.orange)
                    .frame(width: (CGFloat(goal.progress) / 100) * UIScreen.main.bounds.width * 0.75, height: 8)
                    .cornerRadius(4)
            }
        }
    }
}

struct UpcomingActivityRow: View {
    let activity: UpcomingActivity
    
    var body: some View {
        HStack(spacing: 16) {
            // Activity icon
            Image(systemName: activity.iconName)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(activity.color)
                .cornerRadius(12)
            
            // Activity details
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(activity.timeDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Activity action
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}