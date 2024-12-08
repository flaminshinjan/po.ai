import Foundation
import AVFoundation

class ConversationRepository {
    private var audioPlayer: AVAudioPlayer?

    // Generate a question using OpenAI
    func generateBlobQuestion(context: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization") // Replace with your OpenAI API key

        // Adjust the system message and set a lower max_tokens to control response length
        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are a compassionate and friendly mental health professional. Your tone is supportive, non-judgmental, and empathetic, and you provide advice and suggestions in a way that promotes well-being and mental health.
                    """
                ],
                [
                    "role": "user",
                    "content": context
                ]
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("Error: Failed to serialize OpenAI payload.")
            completion("Sorry, I couldn't process that.")
            return
        }

        request.httpBody = jsonData

        print("OpenAI Request Payload: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error calling OpenAI API: \(error)")
                completion("Sorry, something went wrong.")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("OpenAI HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("Error: No data received from OpenAI API.")
                completion("Sorry, I couldn't process that.")
                return
            }

            let responseString = String(data: data, encoding: .utf8) ?? "Invalid UTF-8 Response"
            print("OpenAI Response: \(responseString)")

            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("Error parsing OpenAI response.")
                completion("Sorry, I couldn't process that.")
                return
            }

            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }

    // Convert text to speech using Eleven Labs
    func speakBlob(text: String, completion: @escaping () -> Void) {
            let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/")! // Replace YOUR_VOICE_ID
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("", forHTTPHeaderField: "xi-api-key") // Replace with your Eleven Labs API key

            let payload: [String: Any] = [
                "text": text,
                "voice_settings": [
                    "stability": 0.5,
                    "similarity_boost": 0.5
                ]
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
                print("Error: Failed to serialize Eleven Labs payload.")
                return
            }

            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error calling Eleven Labs API: \(error)")
                    return
                }

                guard let data = data else {
                    print("Error: No data received from Eleven Labs API.")
                    return
                }

                let tempDir = FileManager.default.temporaryDirectory
                let audioFileURL = tempDir.appendingPathComponent("output.mp3")

                do {
                    try data.write(to: audioFileURL)
                    print("Audio file saved at: \(audioFileURL.path)")

                    DispatchQueue.main.async {
                        self.playAudio(from: audioFileURL, completion: completion)
                    }
                } catch {
                    print("Error saving audio file: \(error)")
                }
            }.resume()
        }

        // Play audio
        private func playAudio(from url: URL, completion: @escaping () -> Void) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                print("Playing audio from: \(url.path)")
                completion() // Notify that audio has started
            } catch {
                print("Error playing audio: \(error)")
            }
        }
}
