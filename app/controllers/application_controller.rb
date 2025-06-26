class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :store_user_location!, if: :storable_location?

  # Set default URL options to include locale
  def default_url_options
    { locale: I18n.locale }
  end

  private

  def set_locale
    # Priority order for locale:
    # 1. URL parameter
    # 2. User preference (if signed in)
    # 3. Browser Accept-Language header
    # 4. IP-based geolocation
    # 5. Default locale
    I18n.locale = if params[:locale].present? && I18n.available_locales.map(&:to_s).include?(params[:locale])
                    params[:locale]
    elsif user_signed_in? && current_user.interface_language.present?
                    current_user.language_to_locale(current_user.interface_language)
    else
                    locale_from_http_header || locale_from_ip || I18n.default_locale
    end
  end

  def locale_from_http_header
    http_locale = request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
    return nil unless http_locale

    # Only return the locale if it's available in our application
    http_locale.to_sym if I18n.available_locales.include?(http_locale.to_sym)
  end

  def locale_from_ip
    # Get client IP (accounting for proxies)
    client_ip = request.remote_ip

    # Skip for localhost/development
    return nil if client_ip == "127.0.0.1" || client_ip == "::1"

    # Map IP to country code using Geocoder gem
    # Note: You'll need to add the geocoder gem to your Gemfile
    begin
      country_code = Geocoder.search(client_ip).first&.country_code&.downcase

      # Map country code to locale
      case country_code
      when "es", "mx", "ar", "co", "pe", "cl", "ec", "ve", "gt", "cu", "bo", "do", "hn", "py", "sv", "ni", "cr", "pa", "uy"
        :es if I18n.available_locales.include?(:es)
      when "us", "gb", "ca", "au", "nz", "ie", "za"
        :en if I18n.available_locales.include?(:en)
      # Add more country code to locale mappings as needed
      else
        nil
      end
    rescue => e
      Rails.logger.error "Error determining locale from IP: #{e.message}"
      nil
    end
  end

  # Store the current location for redirect after sign in/out
  def storable_location?
    request.get? &&
    is_navigational_format? &&
    !devise_controller? &&
    !request.xhr? &&
    !turbo_frame_request?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  # Check if request is a turbo frame request
  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end
end
