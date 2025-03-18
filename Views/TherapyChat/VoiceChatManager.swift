import Foundation
import Speech
import AVFoundation

enum VoiceChatState {
    case idle
    case listening
    case processing
    case speaking
}

class VoiceChatManager: NSObject, ObservableObject {
    @Published var state: VoiceChatState = .idle
    @Published var transcript: String = ""
    @Published var isPermissionGranted = false
    @Published var errorMessage: String? = nil
    
    // Speech recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Speech synthesis
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var voiceType: AVSpeechSynthesisVoice?
    
    // Queue for managing synthesis operations
    private let synthQueue = DispatchQueue(label: "com.mindfuljourney.speechSynthesis")
    
    override init() {
        super.init()
        setupVoice()
        requestPermissions()
    }
    
    private func setupVoice() {
        // Find a suitable voice - preferring a natural female voice if available
        if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: {
            $0.quality == .enhanced && $0.gender == .female
        }) {
            self.voiceType = voice
        } else {
            // Fallback to default enhanced voice
            self.voiceType = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Samantha")
        }
        
        speechSynthesizer.delegate = self
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.isPermissionGranted = true
                case .denied, .restricted, .notDetermined:
                    self?.isPermissionGranted = false
                    self?.errorMessage = "Speech recognition permission not granted"
                @unknown default:
                    self?.isPermissionGranted = false
                    self?.errorMessage = "Unknown permission status"
                }
            }
        }
    }
    
    func startListening() {
        guard isPermissionGranted else {
            errorMessage = "Speech recognition permission not granted"
            return
        }
        
        if audioEngine.isRunning {
            stopListening()
            return
        }
        
        transcript = ""
        
        do {
            try startRecording()
            state = .listening
        } catch {
            errorMessage = "Could not start recording: \(error.localizedDescription)"
        }
    }
    
    private func startRecording() throws {
        // Cancel any ongoing tasks
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .default)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest,
              let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            throw NSError(domain: "VoiceChatManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"])
        }
        
        // Configure recognition
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                DispatchQueue.main.async {
                    if self.state == .listening {
                        self.state = .idle
                    }
                }
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            state = .processing
        }
    }
    
    func stopAll() {
        stopListening()
        stopSpeaking()
    }
    
    func speakText(_ text: String, completion: (() -> Void)? = nil) {
        synthQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Stop any ongoing speech
            self.stopSpeaking()
            
            DispatchQueue.main.async {
                self.state = .speaking
            }
            
            let utterance = AVSpeechUtterance(string: text)
            
            // Configure speech parameters
            utterance.voice = self.voiceType
            utterance.rate = 0.5  // Slightly slower than default for therapeutic effect
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            // Store completion handler
            self.speechSynthesizer.speak(utterance)
            
            // Wait for speech to complete before calling completion
            while self.speechSynthesizer.isSpeaking {
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            DispatchQueue.main.async {
                self.state = .idle
                completion?()
            }
        }
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            state = .idle
        }
    }
}

extension VoiceChatManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .idle
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .speaking
        }
    }
}