class MistakeJournalController < ApplicationController
  def index
    # Group mistake journal entries by error type
    @mistake_entries_by_type = MistakeJournalEntry.all
      .order(count: :desc)
      .group_by(&:error_type)
  end
end
