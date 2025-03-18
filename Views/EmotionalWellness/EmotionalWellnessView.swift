import SwiftUI
import Charts

struct EmotionalWellnessView: View {
    @StateObject private var viewModel = EmotionalWellnessViewModel()
    @State private var showingNewEntrySheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards Section
                    summaryCardsSection
                    
                    // Weekly Trends Chart
                    trendChartSection
                    
                    // Recent Entries
                    recentEntriesSection
                    
                    // AI Insights
                    insightsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Emotional Wellness")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewEntrySheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingNewEntrySheet) {
                NewEmotionalEntryView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Summary Cards Section
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            // Mood card
            SummaryCardView(
                title: "Average Mood",
                value: String(format: "%.1f", viewModel.averageMood),
                icon: "face.smiling.fill",
                color: .blue,
                trend: viewModel.moodTrend
            )
            
            // Anxiety card
            SummaryCardView(
                title: "Average Anxiety",
                value: String(format: "%.1f", viewModel.averageAnxiety),
                icon: "waveform.path.ecg",
                color: .red,
                trend: viewModel.anxietyTrend
            )
            
            // Sleep quality card
            SummaryCardView(
                title: "Sleep Quality",
                value: String(format: "%.1f", viewModel.averageSleep),
                icon: "moon.fill",
                color: .purple,
                trend: viewModel.sleepTrend
            )
            
            // Energy level card
            SummaryCardView(
                title: "Energy Level",
                value: String(format: "%.1f", viewModel.averageEnergy),
                icon: "bolt.fill",
                color: .orange,
                trend: viewModel.energyTrend
            )
        }
        .padding(.top, 10)
    }
    
    // MARK: - Trend Chart Section
    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Trends")
                .font(.headline)
                .padding(.leading, 6)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                
                VStack {
                    Chart {
                        ForEach(viewModel.chartData) { item in
                            LineMark(
                                x: .value("Day", item.dayLabel),
                                y: .value("Mood", item.mood)
                            )
                            .foregroundStyle(Color.blue)
                            .symbol(Circle().strokeBorder(Color.blue, lineWidth: 2))
                            
                            LineMark(
                                x: .value("Day", item.dayLabel),
                                y: .value("Anxiety", item.anxiety)
                            )
                            .foregroundStyle(Color.red)
                            .symbol(Circle().strokeBorder(Color.red, lineWidth: 2))
                            
                            LineMark(
                                x: .value("Day", item.dayLabel),
                                y: .value("Sleep", item.sleep)
                            )
                            .foregroundStyle(Color.purple)
                            .symbol(Circle().strokeBorder(Color.purple, lineWidth: 2))
                            
                            LineMark(
                                x: .value("Day", item.dayLabel),
                                y: .value("Energy", item.energy)
                            )
                            .foregroundStyle(Color.orange)
                            .symbol(Circle().strokeBorder(Color.orange, lineWidth: 2))
                        }
                    }
                    .frame(height: 200)
                    
                    // Legend
                    HStack(spacing: 16) {
                        LegendItem(color: .blue, label: "Mood")
                        LegendItem(color: .red, label: "Anxiety")
                        LegendItem(color: .purple, label: "Sleep")
                        LegendItem(color: .orange, label: "Energy")
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }
                .padding()
            }
        }
    }
    
    // MARK: - Recent Entries Section
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.headline)
                .padding(.leading, 6)
            
            if viewModel.entries.isEmpty {
                emptyEntriesView
            } else {
                ForEach(viewModel.entries.sorted(by: { $0.date > $1.date }).prefix(3)) { entry in
                    EmotionalEntryRow(entry: entry, onDelete: {
                        viewModel.deleteEntry(entry)
                    })
                }
                
                if viewModel.entries.count > 3 {
                    NavigationLink(destination: AllEntriesView(viewModel: viewModel)) {
                        Text("View All Entries")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("AI Insights")
                    .font(.headline)
            }
            .padding(.leading, 6)
            
            Text(viewModel.aiInsight)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Empty Entries View
    private var emptyEntriesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.blue.opacity(0.7))
            
            Text("No wellness data yet")
                .font(.headline)
            
            Text("Track your mood, anxiety, sleep quality, and energy levels to see patterns and receive insights.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingNewEntrySheet = true
            }) {
                Text("Add First Entry")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Summary Card View
struct SummaryCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: TrendDirection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                
                trendIcon
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                Text("/ 10")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var trendIcon: some View {
        switch trend {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
                .padding(4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(12)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundColor(.red)
                .padding(4)
                .background(Color.red.opacity(0.2))
                .cornerRadius(12)
        case .neutral:
            Image(systemName: "arrow.right")
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
        }
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Emotional Entry Row
struct EmotionalEntryRow: View {
    let entry: EmotionalEntry
    let onDelete: () -> Void
    
    @State private var isShowingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(entry.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            
            Divider()
            
            // Metrics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricView(label: "Mood", value: entry.moodScore, maxValue: 10, color: .blue)
                MetricView(label: "Anxiety", value: entry.anxietyLevel, maxValue: 10, color: .red)
                MetricView(label: "Sleep", value: entry.sleepQuality, maxValue: 10, color: .purple)
                MetricView(label: "Energy", value: entry.energyLevel, maxValue: 10, color: .orange)
            }
            
            if !entry.notes.isEmpty {
                Button(action: {
                    isShowingDetails.toggle()
                }) {
                    HStack {
                        Text(isShowingDetails ? "Hide Notes" : "Show Notes")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Image(systemName: isShowingDetails ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if isShowingDetails {
                    Text(entry.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Metric View
struct MetricView: View {
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: (CGFloat(value) / CGFloat(maxValue)) * 100, height: 6)
                }
                
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - New Emotional Entry View
struct NewEmotionalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmotionalWellnessViewModel
    
    @State private var moodScore: Double = 5
    @State private var anxietyLevel: Double = 5
    @State private var sleepQuality: Double = 5
    @State private var energyLevel: Double = 5
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How are you feeling today?")) {
                    VStack(alignment: .leading, spacing: 20) {
                        sliderView(
                            value: $moodScore,
                            label: "Mood",
                            minLabel: "Very Low",
                            maxLabel: "Excellent",
                            color: .blue
                        )
                        
                        sliderView(
                            value: $anxietyLevel,
                            label: "Anxiety",
                            minLabel: "None",
                            maxLabel: "Extreme",
                            color: .red
                        )
                        
                        sliderView(
                            value: $sleepQuality,
                            label: "Sleep Quality",
                            minLabel: "Very Poor",
                            maxLabel: "Excellent",
                            color: .purple
                        )
                        
                        sliderView(
                            value: $energyLevel,
                            label: "Energy Level",
                            minLabel: "Exhausted",
                            maxLabel: "Energetic",
                            color: .orange
                        )
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sliderView(value: Binding<Double>, label: String, minLabel: String, maxLabel: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.headline)
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            Slider(value: value, in: 1...10, step: 1)
                .accentColor(color)
            
            HStack {
                Text(minLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(maxLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func saveEntry() {
        let newEntry = EmotionalEntry(
            id: UUID().uuidString,
            date: Date(),
            moodScore: Int(moodScore),
            anxietyLevel: Int(anxietyLevel),
            sleepQuality: Int(sleepQuality),
            energyLevel: Int(energyLevel),
            notes: notes
        )
        
        viewModel.addEntry(newEntry)
    }
}

// MARK: - All Entries View
struct AllEntriesView: View {
    @ObservedObject var viewModel: EmotionalWellnessViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.entries.sorted(by: { $0.date > $1.date })) { entry in
                EmotionalEntryRow(entry: entry, onDelete: {
                    viewModel.deleteEntry(entry)
                })
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
        .navigationTitle("All Entries")
    }
}

struct EmotionalWellnessView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionalWellnessView()
    }
}