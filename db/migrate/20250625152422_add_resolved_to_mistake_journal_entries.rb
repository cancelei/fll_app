class AddResolvedToMistakeJournalEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :mistake_journal_entries, :resolved, :boolean, default: false
    add_column :mistake_journal_entries, :last_occurrence, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
