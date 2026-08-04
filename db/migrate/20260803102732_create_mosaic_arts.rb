class CreateMosaicArts < ActiveRecord::Migration[8.1]
  def change
    create_table :mosaic_arts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :mosaic_design, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end
  end
end
