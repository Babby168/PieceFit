class CreatePieces < ActiveRecord::Migration[8.1]
  def change
    create_table :pieces do |t|
      t.references :mosaic_art, null: false, foreign_key: true
      t.integer :position, null: false
      t.datetime :acquired_at
      t.boolean :is_bonus, null: false, default: false

      t.timestamps
    end
    add_index :pieces, [ :mosaic_art_id, :position ], unique: true
  end
end
