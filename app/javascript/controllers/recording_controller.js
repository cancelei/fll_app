import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recording"
export default class extends Controller {
  static targets = ["startButton", "stopButton", "status", "audioPlayer", "form", "audioData"]
  
  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false
  }
  
  async startRecording() {
    try {
      // Request microphone access
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      
      // Update UI
      this.statusTarget.textContent = "Recording..."
      this.startButtonTarget.disabled = true
      this.stopButtonTarget.disabled = false
      this.isRecording = true
      
      // Create MediaRecorder instance
      this.mediaRecorder = new MediaRecorder(stream)
      
      // Set up event handlers
      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data)
        }
      }
      
      this.mediaRecorder.onstop = () => {
        // Create blob from recorded chunks
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' })
        
        // Create URL for the audio blob and set it to the audio player
        const audioUrl = URL.createObjectURL(audioBlob)
        this.audioPlayerTarget.src = audioUrl
        this.audioPlayerTarget.hidden = false
        
        // Convert blob to base64 for form submission
        this.convertBlobToBase64(audioBlob)
        
        // Reset recording state
        this.audioChunks = []
        this.isRecording = false
        
        // Update UI
        this.statusTarget.textContent = "Recording complete. You can listen to it below."
        this.startButtonTarget.disabled = false
        this.stopButtonTarget.disabled = true
        
        // Stop all tracks in the stream
        stream.getTracks().forEach(track => track.stop())
      }
      
      // Start recording
      this.mediaRecorder.start()
    } catch (error) {
      console.error("Error accessing microphone:", error)
      this.statusTarget.textContent = "Error: Could not access microphone. Please check permissions."
      this.startButtonTarget.disabled = false
      this.stopButtonTarget.disabled = true
    }
  }
  
  stopRecording() {
    if (this.mediaRecorder && this.isRecording) {
      this.mediaRecorder.stop()
    }
  }
  
  convertBlobToBase64(blob) {
    const reader = new FileReader()
    reader.onloadend = () => {
      // Get the base64 data (remove the data URL prefix)
      const base64data = reader.result.split(',')[1]
      // Set the value to the hidden input field
      this.audioDataTarget.value = base64data
    }
    reader.readAsDataURL(blob)
  }
  
  submitForm(event) {
    // Only prevent default if we don't have audio data yet
    if (!this.audioDataTarget.value) {
      event.preventDefault()
      this.statusTarget.textContent = "Please record audio before submitting."
    }
  }
}
