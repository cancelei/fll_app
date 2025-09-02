class PromptsController < ApplicationController
  before_action :set_prompt, only: [ :show ]

  def index
    @prompts = Prompt.all.order(created_at: :desc)
  end

  def show
    # @prompt is set by the before_action
  end

  # Temporary debugging method
  def debug_seed
    Rails.logger.info "=== MANUAL SEED DEBUG ==="
    Rails.logger.info "Current prompts count: #{Prompt.count}"
    
    if Prompt.count == 0
      Rails.logger.info "No prompts found, running seed..."
      load Rails.root.join('db', 'seeds.rb')
    end
    
    redirect_to prompts_path, notice: "Debug complete. Prompts: #{Prompt.count}"
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:id])
  end
end
