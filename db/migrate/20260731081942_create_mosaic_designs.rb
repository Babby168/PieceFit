class CreateMosaicDesigns < ActiveRecord::Migration[8.1]
  def change
    create_table :mosaic_designs do |t|
      t.string :name, null: false
      t.integer :area_size_x, null: false, default: 10
      t.integer :area_size_y, null: false, default: 9

      t.timestamps
    end
  end
end
