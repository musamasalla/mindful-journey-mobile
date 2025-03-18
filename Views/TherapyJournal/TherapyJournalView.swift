import SwiftUI

struct TherapyJournalView: View {
    @StateObject private var viewModel = TherapyJournalViewModel()
    @State private var searchText = ""
    @State private var showingNewEntrySheet = false
    
    var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return viewModel.entries
        } else {
            return viewModel.entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.entries.isEmpty {
                    emptyStateView
                } else {
                    journalListView
                }
            }
            .navigationTitle("Therapy Journal")
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
                NewJournalEntryView(viewModel: viewModel)
            }
        }
        .searchable(
            text: $searchText,
            prompt: "Search entries"
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("Your Journal Is Empty")
                .font(.title2)
                .bold()
            
            Text("Start your therapeutic journey by recording your thoughts, feelings, and insights from your therapy sessions.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Button(action: {
                showingNewEntrySheet = true
            }) {
                Label("Create First Entry", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 240)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            journalTipsView
                .padding(.top, 30)
        }
        .padding()
    }
    
    private var journalListView: some View {
        List {
            ForEach(filteredEntries.sorted(by: { $0.date > $1.date })) { entry in
                JournalEntryRow(entry: entry)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteEntry(id: entry.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            // Edit entry (not implemented in this sample)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
            
            journalTipsView
                .listRowSeparator(.hidden)
                .padding(.vertical, 20)
        }
        .listStyle(.inset)
    }
    
    private var journalTipsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Journaling Tips")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                TipRow(
                    number: "1",
                    tip: "Write freely without judgment — your journal is a safe space."
                )
                
                TipRow(
                    number: "2",
                    tip: "Use feeling words to name specific emotions rather than general terms."
                )
                
                TipRow(
                    number: "3",
                    tip: "Note connections between events and emotions to identify patterns."
                )
                
                TipRow(
                    number: "4",
                    tip: "Review previous entries to track your progress in therapy."
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and date
            HStack {
                Text(entry.title)
                    .font(.headline)
                Spacer()
                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(entry.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                }
            }
            
            // Content with expand/collapse
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.content)
                    .font(.body)
                    .lineLimit(isExpanded ? nil : 3)
                
                if entry.content.count > 150 {
                    Button(action: {
                        isExpanded.toggle()
                    }) {
                        Text(isExpanded ? "Show less" : "Read more")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // AI Therapist reflection (if available)
            if !entry.aiReflection.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain")
                            .foregroundColor(.blue)
                        Text("AI Therapist Reflection")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text(entry.aiReflection)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TipRow: View {
    let number: String
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 24, height: 24)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(Circle())
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct NewJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TherapyJournalViewModel
    
    @State private var title = ""
    @State private var content = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Entry title", text: $title)
                }
                
                Section(header: Text("Your thoughts and feelings")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section(header: 
                    HStack {
                        Text("Tags")
                        Spacer()
                        Text("Optional").font(.caption).foregroundColor(.secondary)
                    }
                ) {
                    HStack {
                        TextField("Add a tag", text: $tagInput)
                        
                        Button(action: addTag) {
                            Text("Add")
                                .fontWeight(.semibold)
                        }
                        .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                            .padding(.leading, 10)
                                            .padding(.trailing, 5)
                                            .padding(.vertical, 5)
                                        
                                        Button(action: {
                                            tags.removeAll { $0 == tag }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.blue.opacity(0.7))
                                        }
                                        .padding(.trailing, 10)
                                    }
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(15)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                Section(header: Text("Prompts (if needed)")) {
                    promptButton("How are you feeling today?")
                    promptButton("What came up in your last therapy session?")
                    promptButton("What's one thing you're grateful for?")
                    promptButton("What's challenging you right now?")
                }
            }
            .navigationTitle("New Journal Entry")
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
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func promptButton(_ prompt: String) -> some View {
        Button(action: {
            if content.isEmpty {
                content = prompt + "\n\n"
            } else {
                content += "\n\n" + prompt + "\n\n"
            }
        }) {
            Text(prompt)
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.vertical, 2)
        }
    }
    
    private func addTag() {
        let trimmedTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else { return }
        
        tags.append(trimmedTag)
        tagInput = ""
    }
    
    private func saveEntry() {
        // Generate AI reflection based on content (in a real app, this would call an API)
        let aiReflection = generateAIReflection(from: content)
        
        let newEntry = JournalEntry(
            id: UUID().uuidString,
            date: Date(),
            title: title,
            content: content,
            tags: tags,
            aiReflection: aiReflection
        )
        
        viewModel.addEntry(newEntry)
        dismiss()
    }
    
    private func generateAIReflection(from content: String) -> String {
        // This is a simple mock implementation
        // In a real app, this would call an API to generate personalized reflections
        
        let contentLowercase = content.lowercased()
        
        // Check for anxiety-related content
        if contentLowercase.contains("anxious") || contentLowercase.contains("anxiety") || 
           contentLowercase.contains("worried") || contentLowercase.contains("stress") {
            return "I notice you're writing about anxiety. Remember that acknowledging these feelings is an important step. Consider trying the breathing exercise we discussed in your next therapy session."
        }
        
        // Check for content about progress
        if contentLowercase.contains("better") || contentLowercase.contains("progress") || 
           contentLowercase.contains("improve") || contentLowercase.contains("growth") {
            return "It's wonderful to see you recognizing your progress. Celebrating these moments, even small ones, reinforces positive patterns and builds resilience."
        }
        
        // Check for content about relationships
        if contentLowercase.contains("relationship") || contentLowercase.contains("friend") || 
           contentLowercase.contains("partner") || contentLowercase.contains("family") {
            return "Relationships are a central part of our wellbeing. As you navigate these dynamics, remember the boundary-setting techniques we've discussed in your therapy sessions."
        }
        
        // Default response
        return "Thank you for sharing your thoughts. Regular journaling like this helps build self-awareness and emotional intelligence, which are important skills in your therapeutic journey."
    }
}

struct TherapyJournalView_Previews: PreviewProvider {
    static var previews: some View {
        TherapyJournalView()
    }
}