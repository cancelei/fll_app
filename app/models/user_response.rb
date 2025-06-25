class UserResponse < ApplicationRecord
  belongs_to :prompt
  has_many :corrections, dependent: :destroy

  # Add ActiveStorage attachment for audio
  has_one_attached :audio

  # Validations
  validates :prompt, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Methods to get transcript with highlights
  def transcript_with_highlights
    return transcript unless corrections.any?

    highlighted_transcript = transcript.dup

    # Sort corrections by their position in the transcript to avoid issues
    # when replacing text (starting from the end to avoid offset issues)
    corrections.sort_by { |c| -transcript.index(c.mistake).to_i }.each do |correction|
      mistake_index = highlighted_transcript.index(correction.mistake)
      next unless mistake_index

      highlighted_transcript[mistake_index, correction.mistake.length] =
        "<error>#{correction.mistake}</error>"
    end

    highlighted_transcript
  end
end
