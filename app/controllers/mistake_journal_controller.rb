class MistakeJournalController < ApplicationController
  def index
    # Get current (unresolved) mistakes
    @current_mistakes = MistakeJournalEntry.where(resolved: false)
      .order(count: :desc)
      .group_by(&:error_type)

    # Get resolved mistakes
    @resolved_mistakes = MistakeJournalEntry.where(resolved: true)
      .order(count: :desc)
      .group_by(&:error_type)

    # Calculate progress metrics
    @total_mistakes = MistakeJournalEntry.count
    @resolved_count = MistakeJournalEntry.where(resolved: true).count
    @progress_percentage = @total_mistakes > 0 ? (@resolved_count.to_f / @total_mistakes * 100).round : 0
  end

  def mark_resolved
    @entry = MistakeJournalEntry.find(params[:id])
    @entry.update(resolved: true)
    redirect_to mistake_journal_index_path, notice: "Mistake marked as resolved!"
  end

  def mark_unresolved
    @entry = MistakeJournalEntry.find(params[:id])
    @entry.update(resolved: false)
    redirect_to mistake_journal_index_path, notice: "Mistake marked as unresolved."
  end
end
