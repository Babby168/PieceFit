class CreateStretches < ActiveRecord::Migration[8.1]
  def change
    create_table :stretches do |t|
      t.string :name, null:false
      t.integer :body_part, null:false, default: 0
      t.text :description, null:false
      t.string :key_visual_path
      t.string :point
      
      t.timestamps
    end
  end
end
