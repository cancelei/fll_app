# Set up I18n configuration
Rails.application.config.i18n.available_locales = [ :en, :es, :pt, :de ]
Rails.application.config.i18n.default_locale = :en

# Load path
Rails.application.config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
