#!/usr/bin/env ruby
# Direct test of AssemblyAI API to verify functionality

require "bundler/setup"
require "assemblyai"
require "dotenv"
require "httplog"
require "logger"

# Load environment variables
Dotenv.load

# Configure HTTP logging
HttpLog.configure do |config|
  config.enabled = true
  config.log_headers = true
  config.log_data = true
  config.log_response = true
  config.logger = Logger.new(STDOUT)
  config.color = false
end

puts "Starting AssemblyAI direct test..."

# Initialize the AssemblyAI client
api_key = ENV["ASSEMBLY_API"]
if api_key.nil? || api_key.empty?
  puts "Error: ASSEMBLY_API environment variable not set"
  exit 1
end

puts "Using API key: #{api_key[0..3]}...#{api_key[-4..-1]}"
client = AssemblyAI::Client.new(api_key: api_key)

# Create a simple WAV file with a sine wave
puts "Creating test audio file..."
test_audio_path = "test_audio.wav"

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

puts "Test audio file created at #{test_audio_path}"

begin
  # Upload the file according to documentation
  puts "Uploading file to AssemblyAI..."
  uploaded_file = client.files.upload(file: test_audio_path)
  puts "File uploaded successfully. Upload URL: #{uploaded_file.upload_url}"

  # Transcribe the audio
  puts "Transcribing audio..."
  transcript = client.transcripts.transcribe(
    audio_url: uploaded_file.upload_url,
    language_code: "en",
    punctuate: true,
    format_text: true
  )

  puts "\nTranscription result:"
  puts "---------------------"
  puts "Transcript ID: #{transcript.id}"
  puts "Status: #{transcript.status}"
  puts "Text: #{transcript.text || 'No transcript generated'}"

rescue => e
  puts "Error during processing: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "Test completed."
