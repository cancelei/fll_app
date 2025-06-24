require 'openai'

class GrammarCorrectionService
  def initialize(user_response)
    @user_response = user_response
    @prompt = @user_response.prompt
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API'])
  end

  def process
    # Check if we have a transcript to analyze
    if @user_response.transcript.blank?
      @user_response.update(
        grammar_score: 0,
        fluency: 'poor',
        overall_feedback: "No transcript available for analysis."
      )
      return @user_response
    end
    
    # Use OpenAI API to analyze grammar
    begin
      corrections = analyze_grammar_with_openai
      
      # Update the user response with feedback
      @user_response.update(
        grammar_score: calculate_grammar_score(corrections),
        fluency: determine_fluency(corrections),
        overall_feedback: generate_overall_feedback(corrections)
      )
      
      # Create correction records and update mistake journal
      corrections.each do |correction|
        create_correction(correction)
        update_mistake_journal(correction)
      end
      
    rescue => e
      # Log the error and use fallback data
      Rails.logger.error("Grammar correction error: #{e.message}")
      fallback_grammar_correction
    end
    
    @user_response
  end

  private
  
  def analyze_grammar_with_openai
    # Prepare the prompt for OpenAI
    system_prompt = """You are an expert English grammar teacher analyzing spoken English responses.
    
    First, determine if the user's response is relevant to the given prompt:
    1. If the response is completely unrelated to the prompt (e.g., answering a different question), flag it as 'off-topic'.
    2. If the response is somewhat related but doesn't directly answer the prompt, flag it as 'partially-relevant'.
    3. If the response addresses the prompt appropriately, proceed with grammar analysis.
    
    For grammar analysis, focus ONLY on these error types: verb-tense, word-order, subject-verb-agreement.
    For each error, identify:
    1. The error type (one of the three categories)
    2. The exact mistake (the incorrect phrase)
    3. The correction (how it should be said)
    4. A brief teaching tip
    
    Return your analysis as a JSON object with these fields:
    - 'relevance': 'on-topic', 'partially-relevant', or 'off-topic'
    - 'relevance_feedback': brief explanation about the relevance issue if not on-topic
    - 'corrections': array of objects with keys: error_type, mistake, correction, tip
    
    If there are no grammar errors but the response is off-topic, still return the relevance information with an empty corrections array."""
    
    user_prompt = """Context prompt: #{@prompt.content}
    
    User's spoken response: #{@user_response.transcript}
    
    First assess relevance, then analyze grammar errors focusing only on verb-tense, word-order, and subject-verb-agreement."""
    
    # Call OpenAI API
    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        response_format: { type: "json_object" }
      }
    )
    
    # Parse the response
    result = JSON.parse(response.dig("choices", 0, "message", "content"))
    
    # Extract relevance information
    relevance = result["relevance"] || "on-topic"
    relevance_feedback = result["relevance_feedback"]
    
    # If the response is off-topic, add a special correction for it
    if relevance != "on-topic"
      @user_response.update(
        overall_feedback: relevance_feedback || "Your response doesn't seem to address the prompt directly."
      )
      
      # Add a special correction for off-topic responses
      return [{
        error_type: "relevance",
        mistake: @user_response.transcript,
        correction: "A response that addresses the prompt: #{@prompt.content}",
        tip: "Make sure your response directly addresses the question or prompt given."
      }]
    end
    
    # Process grammar corrections
    corrections = result["corrections"] || []
    
    # Convert string keys to symbols
    corrections.map do |correction|
      {
        error_type: correction["error_type"],
        mistake: correction["mistake"],
        correction: correction["correction"],
        tip: correction["tip"]
      }
    end
  end
  
  def calculate_grammar_score(corrections)
    # Simple scoring algorithm: start with 10 and subtract points for errors
    base_score = 10
    penalty_per_error = 2
    
    score = base_score - (corrections.length * penalty_per_error)
    [score, 1].max # Ensure score is at least 1
  end
  
  def determine_fluency(corrections)
    case corrections.length
    when 0
      "excellent"
    when 1
      "good"
    when 2
      "fair"
    else
      "poor"
    end
  end
  
  def generate_overall_feedback(corrections)
    if corrections.empty?
      "Excellent job! Your grammar is correct."
    else
      error_types = corrections.map { |c| c[:error_type] }.uniq
      
      if error_types.include?("verb-tense")
        "Good effort! Watch your verb tenses."
      elsif error_types.include?("word-order")
        "Good effort! Pay attention to word order in English sentences."
      elsif error_types.include?("subject-verb-agreement")
        "Good effort! Remember that subjects and verbs must agree."
      else
        "Good effort! Keep practicing to improve your grammar."
      end
    end
  end
  
  def fallback_grammar_correction
    # Fallback implementation when API fails
    @user_response.update(
      grammar_score: 5,
      fluency: 'fair',
      overall_feedback: "Grammar analysis encountered an issue. Here's a general assessment."
    )
    
    # Create a generic correction
    correction = {
      error_type: 'verb-tense',
      mistake: "am work",
      correction: "have been working",
      tip: "Use present perfect continuous for ongoing past actions"
    }
    
    create_correction(correction)
    update_mistake_journal(correction)
  end

  def create_correction(correction_data)
    @user_response.corrections.create!(
      error_type: correction_data[:error_type],
      mistake: correction_data[:mistake],
      correction: correction_data[:correction],
      tip: correction_data[:tip]
    )
  end

  def update_mistake_journal(correction_data)
    entry = MistakeJournalEntry.find_or_initialize_by(
      error_type: correction_data[:error_type],
      mistake: correction_data[:mistake]
    )
    
    entry.count ||= 0
    entry.count += 1
    entry.save!
  end
end
