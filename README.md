# MindfulJourney Mobile - AI Therapy Companion

MindfulJourney Mobile is an iOS application that provides AI-powered therapy sessions, emotional wellness tracking, and mental health support. The app features an intuitive interface with a calming color palette, making it easy for users to engage with their AI therapist anytime, anywhere.

## Features

- **AI Therapy Sessions**: Access personalized therapy sessions through conversational AI trained on evidence-based therapeutic approaches
- **Emotional Wellness Tracking**: Track emotions, triggers, and patterns affecting your mental health
- **Guided Therapeutic Exercises**: Access CBT, DBT, and mindfulness exercises tailored to your specific needs
- **Therapy Journal**: Document thoughts with AI-guided therapeutic prompts
- **Progress Tracking**: Visualize your therapeutic journey over time with insights
- **Crisis Resources**: Quickly access mental health crisis resources when needed
- **Session Scheduling**: Set reminders for regular therapy check-ins
- **Therapy Goals**: Set and track progress toward your therapy goals
- **Therapy Notes**: Review key insights from past therapy sessions

## Technical Details

MindfulJourney Mobile is built using:
- Swift and SwiftUI for the user interface
- MVVM architecture for clean separation of concerns
- Supabase for backend services and authentication
- OpenAI integration for AI-powered therapy responses
- Combine framework for reactive programming
- UserDefaults and CoreData for persistent storage
- AVFoundation for audio guided exercises
- WidgetKit for home screen therapy reminders

## Therapeutic Approaches

The AI therapist is designed to implement several evidence-based therapeutic approaches:

1. **Cognitive Behavioral Therapy (CBT)**: Identifying and challenging negative thought patterns
2. **Dialectical Behavior Therapy (DBT)**: Mindfulness, distress tolerance, emotion regulation
3. **Acceptance and Commitment Therapy (ACT)**: Acceptance and mindfulness strategies
4. **Solution-Focused Brief Therapy**: Goal-oriented, solution-focused approaches
5. **Motivational Interviewing**: Techniques to increase motivation for positive change

## Backend Services

The app uses Supabase for its backend services:
- **Therapy Sessions**: Stores and manages therapy conversation history
- **Emotional Tracking**: Stores and analyzes emotional wellness data
- **User Profiles**: Maintains therapy goals and preferences
- **Journal Entries**: Securely stores journal entries with encryption
- **Crisis Resources**: Provides localized mental health crisis information

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Install the required dependencies
4. Configure your Supabase and OpenAI API keys
5. Build and run the application on your iOS device or simulator

## Important Disclaimers

- MindfulJourney is not a replacement for professional mental health treatment
- In case of emergency, please contact local emergency services or crisis hotlines
- All AI therapy interactions are based on established therapeutic protocols but should be used as a supplement to professional care when needed

## Design Principles

MindfulJourney Mobile adheres to these key design principles:

1. **Therapeutic Alliance**: Design that fosters trust and connection with the AI therapist
2. **Emotional Safety**: Careful consideration of user emotional state throughout the experience
3. **Reduced Friction**: Simple, intuitive interfaces that require minimal cognitive effort
4. **Calming Aesthetics**: Soothing color palette and generous whitespace to reduce anxiety
5. **Progressive Disclosure**: Information presented gradually to avoid overwhelming users
6. **Positive Reinforcement**: Celebration of therapeutic progress and milestones
7. **Accessibility**: WCAG 2.1 AA compliance for all users
8. **Crisis Support**: One-tap access to crisis resources

## Companion Web Application

MindfulJourney has a companion web application available at [MindfulJourney Web](https://github.com/musamasalla/mindful-journey-web) for a complete therapeutic experience.

## License

This project is licensed under the MIT License - see the LICENSE file for details.