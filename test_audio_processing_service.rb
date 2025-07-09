#!/usr/bin/env ruby
# This is a standalone test script for AudioProcessingService
# It doesn't rely on Rails test fixtures

require_relative "config/environment"
require "httplog"

# Configure HTTP logging for debugging
HttpLog.configure do |config|
  config.enabled = true
  config.log_headers = true
  config.log_data = true  # For request body
  config.log_response = true  # For response body
  config.logger = Logger.new(STDOUT)
  config.color = false
end

puts "Creating test audio file..."
# Create a test audio file (simple sine wave)
sample_rate = 44100  # Hz
duration = 3         # seconds
frequency = 440      # Hz (A4 note)
amplitude = 0.5      # Amplitude of the sine wave

# Generate WAV file with sine wave
file_path = Rails.root.join("tmp", "test_audio.wav")
File.open(file_path, "wb") do |file|
  # WAV header
  file.write("RIFF")
  file.write([ 36 + sample_rate * duration * 2 ].pack("V"))  # File size
  file.write("WAVE")
  file.write("fmt ")
  file.write([ 16 ].pack("V"))  # Subchunk1Size
  file.write([ 1 ].pack("v"))   # AudioFormat (PCM)
  file.write([ 1 ].pack("v"))   # NumChannels (Mono)
  file.write([ sample_rate ].pack("V"))  # SampleRate
  file.write([ sample_rate * 2 ].pack("V"))  # ByteRate
  file.write([ 2 ].pack("v"))   # BlockAlign
  file.write([ 16 ].pack("v"))  # BitsPerSample
  file.write("data")
  file.write([ sample_rate * duration * 2 ].pack("V"))  # Subchunk2Size

  # Audio data (sine wave)
  (sample_rate * duration).to_i.times do |i|
    # Generate sine wave sample
    sample = (amplitude * 32767 * Math.sin(2 * Math::PI * frequency * i / sample_rate)).to_i
    file.write([ sample ].pack("s"))  # Write 16-bit sample
  end
end

puts "Test audio file created at #{file_path}"

# Create a blob from the test audio file
puts "Creating ActiveStorage blob..."
audio_blob = nil
File.open(file_path, "rb") do |io|
  audio_blob = ActiveStorage::Blob.create_and_upload!(
    io: io,
    filename: "test_audio.wav",
    content_type: "audio/wav"
  )
end

puts "Creating test prompt and user response..."
# Create a test prompt and user response
prompt = Prompt.create!(content: "Test prompt for audio processing", category: "grammar")
user_response = UserResponse.create!(prompt: prompt)

puts "Processing audio with AudioProcessingService..."
# Process the audio with AudioProcessingService
service = AudioProcessingService.new(audio_blob, user_response)
result = service.process

puts "AudioProcessingService processing complete!"
puts "User response transcript: #{result.transcript.inspect}"

# Clean up
puts "Cleaning up..."
File.unlink(file_path) if File.exist?(file_path)

puts "Test completed!"
