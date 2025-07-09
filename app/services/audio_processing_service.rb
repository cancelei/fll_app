require "assemblyai"

class AudioProcessingService
  def initialize(audio_blob, user_response)
    @audio_blob = audio_blob
    @user_response = user_response
    @client = AssemblyAI::Client.new(api_key: ENV["ASSEMBLY_API"])
  end

  def process
    attach_audio
    transcribe_audio
    @user_response
  end

  private

  def attach_audio
    @user_response.audio.attach(@audio_blob)
  end

  def transcribe_audio
    begin
      # Get the audio file from ActiveStorage
      audio_file = @user_response.audio.download

      # Create a temporary file with the correct extension
      temp_file = Tempfile.new([ "audio", ".webm" ])
      temp_file.binmode
      temp_file.write(audio_file)
      temp_file.rewind

      # Upload the audio file to AssemblyAI using the correct API pattern
      uploaded_file = @client.files.upload(file: temp_file.path)

      # Create a transcription request with the uploaded audio URL
      # Using English language for language learning focus
      transcript = @client.transcripts.transcribe(
        audio_url: uploaded_file.upload_url,
        language_code: "en",
        punctuate: true,
        format_text: true
      )

      # The transcribe method already polls for completion, so we don't need to manually poll
      # Update the user response with the transcription
      if transcript.status == "completed"
        @user_response.update(transcript: transcript.text)
      else
        raise "Transcription failed with status: #{transcript.status}"
      end

    rescue => e
      # Log the error and use a fallback transcript
      Rails.logger.error("Transcription error: #{e.message}")
      @user_response.update(transcript: "[Transcription failed. Please try again.]")
    ensure
      # Clean up the temporary file
      temp_file.close
      temp_file.unlink if temp_file
    end
  end
end
