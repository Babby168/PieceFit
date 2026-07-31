class CreateDesignPieces < ActiveRecord::Migration[8.1]
  def change
    create_table :design_pieces do |t|
      t.references :mosaic_design, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :color, array: true, null: false, default: []

      t.timestamps
    end
  end
end
