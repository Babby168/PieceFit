class AddDetailsToMosaicArts < ActiveRecord::Migration[8.1]
  def change
    add_column :mosaic_arts, :image_url, :string
    add_column :mosaic_arts, :image_public_id, :string
  end
end
