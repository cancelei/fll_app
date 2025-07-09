require "test_helper"

class AudioProcessingServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    # Create a test audio blob
    @audio_blob = create_test_audio_blob

    # Create a test prompt directly instead of using fixtures
    @prompt = Prompt.create!(content: "Test prompt content", category: "grammar")

    # Create a user response
    @user_response = UserResponse.create!(prompt: @prompt)
  end

  test "process attaches audio and transcribes successfully" do
    # Mock the AssemblyAI client
    mock_client = Minitest::Mock.new
    mock_files = Minitest::Mock.new
    mock_uploaded_file = Minitest::Mock.new
    mock_transcripts = Minitest::Mock.new
    mock_transcript = Minitest::Mock.new

    # Set up expectations
    mock_uploaded_file.expect :upload_url, "https://example.com/test-audio.webm"
    mock_transcript.expect :status, "completed"
    mock_transcript.expect :text, "This is a test transcript."

    # Mock the files upload method
    mock_files.expect :upload, mock_uploaded_file, [ Hash ]
    mock_client.expect :files, mock_files

    # Mock the transcripts transcribe method
    mock_transcripts.expect :transcribe, mock_transcript, [ Hash ]
    mock_client.expect :transcripts, mock_transcripts

    # Replace the real client with our mock
    AssemblyAI::Client.stub :new, mock_client do
      service = AudioProcessingService.new(@audio_blob, @user_response)
      result = service.process

      # Verify audio was attached
      assert @user_response.audio.attached?

      # Verify transcript was updated
      assert_equal "This is a test transcript.", @user_response.transcript
    end

    # Verify all mocks were called as expected
    mock_client.verify
    mock_files.verify
    mock_uploaded_file.verify
    mock_transcripts.verify
    mock_transcript.verify
  end

  test "process handles transcription errors" do
    # Mock the AssemblyAI client for error case
    mock_client = Minitest::Mock.new
    mock_files = Minitest::Mock.new
    mock_uploaded_file = Minitest::Mock.new
    mock_transcripts = Minitest::Mock.new
    mock_transcript = Minitest::Mock.new

    # Set up expectations for error case
    mock_uploaded_file.expect :upload_url, "https://example.com/test-audio.webm"
    mock_transcript.expect :status, "error"

    # Mock the files upload method
    mock_files.expect :upload, mock_uploaded_file, [ Hash ]
    mock_client.expect :files, mock_files

    # Mock the transcripts transcribe method
    mock_transcripts.expect :transcribe, mock_transcript, [ Hash ]
    mock_client.expect :transcripts, mock_transcripts

    # Replace the real client with our mock
    AssemblyAI::Client.stub :new, mock_client do
      service = AudioProcessingService.new(@audio_blob, @user_response)
      result = service.process

      # Verify audio was attached
      assert @user_response.audio.attached?

      # Verify fallback transcript was used
      assert_equal "[Transcription failed. Please try again.]", @user_response.transcript
    end
  end

  private

  def create_test_audio_blob
    # Create a simple audio file for testing
    file = Tempfile.new([ "test", ".webm" ])
    file.binmode
    file.write("test audio content")
    file.rewind

    # Create an ActiveStorage blob
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: "test-audio.webm",
      content_type: "audio/webm"
    )

    file.close
    file.unlink

    blob
  end
end
