class CreateCorrections < ActiveRecord::Migration[8.0]
  def change
    create_table :corrections do |t|
      t.references :user_response, null: false, foreign_key: true
      t.string :error_type
      t.string :mistake
      t.string :correction
      t.text :tip

      t.timestamps
    end
  end
end
