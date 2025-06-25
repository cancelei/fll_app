require "openai"

class AudioProcessingService
  def initialize(audio_blob, user_response)
    @audio_blob = audio_blob
    @user_response = user_response
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API"])
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

      # Call OpenAI's transcription API
      response = @client.audio.transcribe(
        parameters: {
          model: "whisper-1",
          file: File.open(temp_file.path)
        }
      )

      # Update the user response with the transcription
      transcript = response["text"]
      @user_response.update(transcript: transcript)

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
