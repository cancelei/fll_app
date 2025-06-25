class PromptsController < ApplicationController
  before_action :set_prompt, only: [ :show ]

  def index
    @prompts = Prompt.all.order(created_at: :desc)
  end

  def show
    # @prompt is set by the before_action
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:id])
  end
end
