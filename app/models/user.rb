class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :username, presence: true, uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 25 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }

  # Language preferences
  AVAILABLE_LANGUAGES = %w[english spanish portuguese german].freeze

  # Map between language names and locale symbols
  LANGUAGE_TO_LOCALE = {
    "english" => :en,
    "spanish" => :es,
    "portuguese" => :pt,
    "german" => :de
  }.freeze

  # Set default values for language preferences
  after_initialize :set_default_preferences, if: :new_record?

  # Virtual attribute for ranking (to be implemented)
  def rank
    # This will be implemented in the future
    "Coming Soon"
  end

  # Convert language name to locale symbol
  def language_to_locale(language)
    LANGUAGE_TO_LOCALE[language] || :en
  end

  private

  def set_default_preferences
    self.preferred_language ||= "english"
    self.interface_language ||= "english"
  end
end
