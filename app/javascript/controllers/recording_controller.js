import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recording"
export default class extends Controller {
  static targets = ["recordButton", "status", "audioPlayer", "form", "audioData"]
  static values = {
    startText: String,
    inProgressText: String,
    processingText: String,
    microphoneErrorText: String
  }
  
  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false
    this.updateButtonState()
  }
  
  async toggleRecording() {
    if (this.isRecording) {
      this.stopRecording()
      return
    }

    try {
      // Request microphone access
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      
      // Update UI
      this.statusTarget.textContent = this.inProgressTextValue
      this.isRecording = true
      this.updateButtonState()
      
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
        this.statusTarget.textContent = this.processingTextValue
        this.updateButtonState()
        
        // Stop all tracks in the stream
        stream.getTracks().forEach(track => track.stop())
        
        // Auto-submit form after a short delay to ensure audio data is ready
        setTimeout(() => {
          if (this.audioDataTarget.value) {
            const form = this.element.querySelector('form')
            if (form) form.submit()
          }
        }, 1000)
      }
      
      // Start recording
      this.mediaRecorder.start()
    } catch (error) {
      console.error("Error accessing microphone:", error)
      this.statusTarget.textContent = this.microphoneErrorTextValue
      this.isRecording = false
      this.updateButtonState()
    }
  }
  
  stopRecording() {
    if (this.mediaRecorder && this.isRecording) {
      this.mediaRecorder.stop()
    }
  }
  
  updateButtonState() {
    const button = this.recordButtonTarget
    
    if (this.isRecording) {
      button.classList.remove('bg-blue-600', 'hover:bg-blue-700')
      button.classList.add('bg-red-600', 'hover:bg-red-700', 'animate-pulse')
      button.querySelector('.button-text').textContent = this.inProgressTextValue
    } else {
      button.classList.remove('bg-red-600', 'hover:bg-red-700', 'animate-pulse')
      button.classList.add('bg-blue-600', 'hover:bg-blue-700')
      button.querySelector('.button-text').textContent = this.startTextValue
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
