class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts do |t|
      t.text :content
      t.string :category
      t.string :difficulty_level

      t.timestamps
    end
  end
end
