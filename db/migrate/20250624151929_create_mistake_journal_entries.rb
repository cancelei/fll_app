class CreateMistakeJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :mistake_journal_entries do |t|
      t.string :error_type
      t.string :mistake
      t.integer :count

      t.timestamps
    end
  end
end
