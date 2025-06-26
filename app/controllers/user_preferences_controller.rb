class UserPreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      # Set locale based on interface language preference
      I18n.locale = @user.language_to_locale(@user.interface_language) if @user.interface_language.present?

      redirect_to edit_user_preferences_path, notice: t("user_preferences.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:preferred_language, :interface_language)
  end
end
