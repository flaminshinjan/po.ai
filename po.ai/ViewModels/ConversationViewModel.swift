import Foundation
import Speech

class ConversationViewModel: ObservableObject {
    @Published var responseText: String = "Let’s talk out your problems one at a time."
    @Published var isProcessing: Bool = false // Track whether the app is processing

    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    private let repository = ConversationRepository()

    // Start listening for voice input
    func startListening() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognition is not available.")
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.responseText = result.bestTranscription.formattedString
                }
            }

            if let error = error {
                print("Error during recognition: \(error)")
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    // Stop listening and return the captured text
    func stopListening(completion: @escaping (String) -> Void) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()

        completion(responseText)
    }

    // Process the captured text with GPT API
    func processText(text: String) {
        isProcessing = true // Start processing

        repository.generateBlobQuestion(context: text) { response in
            DispatchQueue.main.async {
                self.responseText = "Processing response..." // Interim message
            }
            
            // Speak the response and stop loader only after playback starts
            self.repository.speakBlob(text: response) {
                DispatchQueue.main.async {
                    self.responseText = response // Update text after audio starts
                    self.isProcessing = false   // Stop processing
                }
            }
        }
    }
}
