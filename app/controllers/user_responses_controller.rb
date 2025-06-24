class UserResponsesController < ApplicationController
  before_action :set_user_response, only: [:show]
  
  def new
    @prompt = Prompt.find(params[:prompt_id])
    @user_response = UserResponse.new(prompt: @prompt)
  end

  def create
    @prompt = Prompt.find(params[:prompt_id])
    @user_response = UserResponse.new(prompt: @prompt)
    
    # Process the audio data if it exists
    if params[:audio_data].present?
      # Convert base64 to blob
      audio_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(Base64.decode64(params[:audio_data])),
        filename: "recording-#{Time.current.to_i}.webm",
        content_type: 'audio/webm'
      )
      
      # Process the audio using our service
      @user_response = AudioProcessingService.new(audio_blob, @user_response).process
      
      # Process grammar correction
      GrammarCorrectionService.new(@user_response).process
      
      if @user_response.save
        redirect_to user_response_path(@user_response), notice: 'Your response was successfully recorded and analyzed.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Please record audio before submitting.'
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # @user_response is set by the before_action
  end

  def index
    @user_responses = UserResponse.recent.includes(:prompt, :corrections).page(params[:page]).per(10)
  end
  
  private
  
  def set_user_response
    @user_response = UserResponse.find(params[:id])
  end
end
