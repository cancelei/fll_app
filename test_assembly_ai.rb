#!/usr/bin/env ruby
# This script tests the AssemblyAI integration directly

require_relative "config/environment"
require "tempfile"

# Create a simple audio file for testing
puts "Creating test audio file..."
test_audio_path = Rails.root.join("tmp", "test_audio.webm")
`touch #{test_audio_path}` unless File.exist?(test_audio_path)

# Create a blob from the test audio file
puts "Creating ActiveStorage blob..."
audio_blob = ActiveStorage::Blob.create_and_upload!(
  io: File.open(test_audio_path),
  filename: "test_audio.webm",
  content_type: "audio/webm"
)

# Create a user response object
puts "Creating user response..."
prompt = Prompt.first || Prompt.create!(content: "Test prompt")
user_response = UserResponse.create!(
  prompt: prompt
)

# Process the audio using our service
puts "Processing audio with AssemblyAI..."
begin
  service = AudioProcessingService.new(audio_blob, user_response)
  result = service.process

  puts "Transcription result:"
  puts "---------------------"
  puts "Transcript: #{result.transcript || 'No transcript generated'}"
  puts "Status: Success"
rescue => e
  puts "Error during processing: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "Test completed."
