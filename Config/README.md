# MindfulJourney Mobile App Configuration

This guide explains how to set up the necessary configuration for the MindfulJourney iOS app.

## API Configuration

Create a file named `Config.swift` in the Config directory with the following structure:

```swift
import Foundation

struct AppConfig {
    static let supabaseURL = "https://your-supabase-project-url.supabase.co"
    static let supabaseAnonKey = "your-supabase-anon-key"
    static let openAIAPIKey = "your-openai-api-key"
    
    // Voice synthesis API key (optional)
    static let voiceAPIKey = "your-voice-api-key"
    
    // Application settings
    static let apiTimeout: TimeInterval = 30.0
    static let maxSessionHistoryItems = 100
}
```

## Supabase Setup

To configure your Supabase backend:

1. Create a Supabase project at [https://supabase.com](https://supabase.com)
2. Set up the following database tables:

### Table: profiles

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  therapy_goals TEXT[],
  therapy_preferences JSONB,
  emergency_contact JSONB
);
```

### Table: therapy_sessions

```sql
CREATE TABLE therapy_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  title TEXT,
  summary TEXT,
  duration INTEGER,
  mood_before SMALLINT,
  mood_after SMALLINT,
  therapist_notes TEXT,
  topics TEXT[],
  therapy_approaches TEXT[]
);
```

### Table: session_messages

```sql
CREATE TABLE session_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES therapy_sessions(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  content TEXT NOT NULL,
  role TEXT NOT NULL,
  is_voice BOOLEAN DEFAULT FALSE
);
```

### Table: journal_entries

```sql
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  title TEXT,
  content TEXT,
  mood SMALLINT,
  tags TEXT[],
  ai_insights TEXT
);
```

### Table: emotional_entries

```sql
CREATE TABLE emotional_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  date DATE NOT NULL,
  anxiety_level SMALLINT,
  depression_level SMALLINT,
  stress_level SMALLINT,
  sleep_quality SMALLINT,
  overall_mood SMALLINT,
  notes TEXT,
  contributing_factors TEXT[]
);
```

### Additional Setup

1. Enable Row Level Security (RLS) on all tables
2. Create appropriate policies to ensure users can only access their own data
3. Set up authentication providers (email, social logins, etc.)

## OpenAI API Configuration

1. Obtain an API key from [OpenAI](https://openai.com/api/)
2. Add it to your `Config.swift` file

## Build and Run

After setting up the configuration:

1. Open `MindfulJourney.xcodeproj` in Xcode
2. Build and run the application on your target device or simulator

## Security Note

Never commit your actual API keys to version control. The `Config.swift` file should be added to your `.gitignore` file. The template file included in this repository is for reference only.

## Voice Functionality

If you want to use the voice chat feature:

1. Ensure your device has microphone permissions enabled
2. Request speech recognition permissions on first use
3. Configure any additional voice API keys if you're using third-party voice services