class CreateStretchSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :stretch_steps do |t|
      t.references :stretch, null: false, foreign_key: true
      t.integer :step_number, null: false
      t.string :image_path, null: false
      t.text :description, null: false

      t.timestamps
    end
    add_index :stretch_steps, [ :stretch_id, :step_number ], unique: true
  end
end
