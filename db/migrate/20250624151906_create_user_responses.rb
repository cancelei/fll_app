class CreateUserResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_responses do |t|
      t.references :prompt, null: false, foreign_key: true
      t.text :transcript
      t.integer :grammar_score
      t.string :fluency
      t.text :overall_feedback

      t.timestamps
    end
  end
end
