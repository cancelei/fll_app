#!/usr/bin/env ruby
# This script tests the AssemblyAI integration with a real audio file

require_relative "config/environment"
require "tempfile"
require "open-uri"

# Create a simple WAV file with actual audio data
puts "Setting up test audio file..."
test_audio_path = Rails.root.join("tmp", "test_audio", "sample_audio.wav")

begin
  # Create a test audio file if it doesn't exist
  unless File.exist?(test_audio_path)
    puts "Creating WAV audio file..."

    # Create a simple WAV file with a sine wave
    File.open(test_audio_path, "wb") do |file|
      # RIFF header
      file.write("RIFF")
      file.write([ 36 + 8000 * 2 ].pack("V")) # File size
      file.write("WAVE")

      # Format chunk
      file.write("fmt ")
      file.write([ 16 ].pack("V")) # Chunk size
      file.write([ 1 ].pack("v")) # Audio format (1 = PCM)
      file.write([ 1 ].pack("v")) # Number of channels
      file.write([ 8000 ].pack("V")) # Sample rate
      file.write([ 8000 * 2 ].pack("V")) # Byte rate
      file.write([ 2 ].pack("v")) # Block align
      file.write([ 16 ].pack("v")) # Bits per sample

      # Data chunk
      file.write("data")
      file.write([ 8000 * 2 ].pack("V")) # Chunk size

      # Generate a simple sine wave (1 second at 440Hz)
      8000.times do |i|
        value = (Math.sin(2 * Math::PI * 440 * i / 8000) * 32767).to_i
        file.write([ value ].pack("s"))
      end
    end

    puts "WAV audio file created at #{test_audio_path}"
  else
    puts "Using existing audio file at #{test_audio_path}"
  end

  # Create a blob from the test audio file
  puts "Creating ActiveStorage blob..."
  audio_blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(test_audio_path),
    filename: "sample_audio.wav",
    content_type: "audio/wav"
  )

  # Create a user response object
  puts "Creating user response..."
  prompt = Prompt.first || Prompt.create!(content: "Test prompt")
  user_response = UserResponse.create!(
    prompt: prompt
  )

  # Add HTTP request debugging
  puts "Enabling HTTP request debugging..."
  require 'httplog'
  HttpLog.configure do |config|
    config.enabled = true
    config.log_headers = true
    config.log_data = true
    config.log_response = true
    config.logger = Logger.new(STDOUT)
    config.color = false
  end

  # Process the audio using our service
  puts "Processing audio with AssemblyAI..."
  begin
    # Enable HTTP request logging
    require 'httplog'
    HttpLog.configure do |config|
      config.enabled = true
      config.log_headers = true
      config.log_data = true
      config.log_response = true
      config.logger = Logger.new(STDOUT)
      config.color = false
    end

    service = AudioProcessingService.new(audio_blob, user_response)
    result = service.process

    puts "\nTranscription result:"
    puts "---------------------"
    puts "Transcript: #{result.transcript || 'No transcript generated'}"
    puts "Status: Success"
  rescue => e
    puts "\nError during processing: #{e.message}"
    puts e.backtrace.join("\n")
  end

rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "Test completed."
