# This file contains seed data for the English Grammar Feedback app
# Run with: bin/rails db:seed

# Clear existing data to avoid duplicates
puts "Clearing existing data..."
MistakeJournalEntry.destroy_all
Correction.destroy_all
UserResponse.destroy_all
Prompt.destroy_all

# Create prompts for different categories
puts "Creating prompts..."

# Work-related prompts
work_prompts = [
  {
    content: "How long have you been working at your current company?",
    category: "work",
    difficulty_level: "beginner"
  },
  {
    content: "Can you describe your typical workday?",
    category: "work",
    difficulty_level: "beginner"
  },
  {
    content: "What projects are you currently working on?",
    category: "work",
    difficulty_level: "intermediate"
  },
  {
    content: "If you could change one thing about your workplace, what would it be?",
    category: "work",
    difficulty_level: "advanced"
  }
]

# Social conversation prompts
social_prompts = [
  {
    content: "What did you do last weekend?",
    category: "social",
    difficulty_level: "beginner"
  },
  {
    content: "What are your plans for the upcoming holiday?",
    category: "social",
    difficulty_level: "intermediate"
  },
  {
    content: "Tell me about a memorable trip you've taken.",
    category: "social",
    difficulty_level: "intermediate"
  },
  {
    content: "If you could travel anywhere in the world, where would you go and why?",
    category: "social",
    difficulty_level: "advanced"
  }
]

# Meeting participation prompts
meeting_prompts = [
  {
    content: "How would you introduce yourself in a team meeting?",
    category: "meetings",
    difficulty_level: "beginner"
  },
  {
    content: "Can you explain a problem you're facing with a current project?",
    category: "meetings",
    difficulty_level: "intermediate"
  },
  {
    content: "How would you suggest an improvement to a team process?",
    category: "meetings",
    difficulty_level: "advanced"
  },
  {
    content: "Summarize the main points from our last discussion about the marketing strategy.",
    category: "meetings",
    difficulty_level: "advanced"
  }
]

# Job interview prompts
interview_prompts = [
  {
    content: "Tell me about yourself and your background.",
    category: "interview",
    difficulty_level: "beginner"
  },
  {
    content: "Why are you interested in this position?",
    category: "interview",
    difficulty_level: "intermediate"
  },
  {
    content: "Describe a challenging situation you faced at work and how you resolved it.",
    category: "interview",
    difficulty_level: "advanced"
  },
  {
    content: "Where do you see yourself professionally in five years?",
    category: "interview",
    difficulty_level: "advanced"
  }
]

# Combine all prompts and create records
all_prompts = work_prompts + social_prompts + meeting_prompts + interview_prompts

all_prompts.each do |prompt_data|
  Prompt.create!(prompt_data)
end

puts "Created #{Prompt.count} prompts"

# Create some sample user responses and corrections for testing
puts "Creating sample user responses and corrections..."

# Find a prompt to use
sample_prompt = Prompt.find_by(content: "How long have you been working at your current company?")

if sample_prompt
  # Create a user response with simulated audio
  user_response = UserResponse.new(
    prompt: sample_prompt,
    transcript: "I am work here since 2021",
    grammar_score: 4,
    fluency: "fair",
    overall_feedback: "Good effort! Watch your verb tenses."
  )

  # Note: In a real app, we would attach an actual audio file
  # For seeds, we'll skip the audio attachment
  user_response.save(validate: false) # Skip validations since we don't have real audio

  # Create a correction for this response
  correction = Correction.create!(
    user_response: user_response,
    error_type: "verb-tense",
    mistake: "am work",
    correction: "have been working",
    tip: "Use present perfect continuous for ongoing past actions"
  )

  # Create mistake journal entries - both current and resolved

  # Current mistakes (unresolved)
  MistakeJournalEntry.create!(
    error_type: "verb-tense",
    mistake: "am work",
    count: 3,
    resolved: false,
    last_occurrence: 2.days.ago
  )

  MistakeJournalEntry.create!(
    error_type: "verb-tense",
    mistake: "I working",
    count: 2,
    resolved: false,
    last_occurrence: 1.day.ago
  )

  MistakeJournalEntry.create!(
    error_type: "word-order",
    mistake: "I like very much coffee",
    count: 4,
    resolved: false,
    last_occurrence: 3.days.ago
  )

  MistakeJournalEntry.create!(
    error_type: "subject-verb-agreement",
    mistake: "The team are working",
    count: 2,
    resolved: false,
    last_occurrence: 5.days.ago
  )

  # Resolved mistakes
  MistakeJournalEntry.create!(
    error_type: "verb-tense",
    mistake: "I am go",
    count: 1,
    resolved: true,
    last_occurrence: 14.days.ago
  )

  MistakeJournalEntry.create!(
    error_type: "word-order",
    mistake: "Yesterday I went to quickly the store",
    count: 2,
    resolved: true,
    last_occurrence: 10.days.ago
  )

  MistakeJournalEntry.create!(
    error_type: "subject-verb-agreement",
    mistake: "She don't like coffee",
    count: 3,
    resolved: true,
    last_occurrence: 7.days.ago
  )

  puts "Created sample user response with correction"
end

puts "Seed data creation complete!"
