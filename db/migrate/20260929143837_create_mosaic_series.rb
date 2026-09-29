class CreateMosaicSeries < ActiveRecord::Migration[8.1]
  def up
    create_table :mosaic_series do |t|
      t.string :name, null: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :mosaic_series, :name, unique: true
    add_index :mosaic_series, :position, unique: true

    add_reference :mosaic_designs, :mosaic_series, foreign_key: true, null: true
    add_column :mosaic_designs, :collection_position, :integer

    backfill_from_yaml!

    change_column_null :mosaic_designs, :mosaic_series_id, false
    change_column_null :mosaic_designs, :collection_position, false
    add_index :mosaic_designs, [ :mosaic_series_id, :collection_position ],
              unique: true,
              name: "index_mosaic_designs_on_series_and_position"
  end

  def down
    remove_index :mosaic_designs, name: "index_mosaic_designs_on_series_and_position"
    remove_column :mosaic_designs, :collection_position
    remove_reference :mosaic_designs, :mosaic_series, foreign_key: true
    drop_table :mosaic_series
  end

  private

  def backfill_from_yaml!
    MosaicSeries.reset_column_information
    MosaicDesign.reset_column_information

    series_by_name = {}
    series_rows.each do |row|
      series = MosaicSeries.create!(name: row["name"], position: row["position"])
      series_by_name[series.name] = series
    end

    Dir.glob(Rails.root.join("db/seed_data/mosaic_designs/colors/*.yml")).each do |yaml_path|
      data = YAML.safe_load_file(yaml_path, permitted_classes: [ Symbol ], aliases: true)

      series = series_by_name[data["series_name"]]
      raise "未知のシリーズです: #{data["series_name"]} (#{yaml_path})" if series.nil?

      MosaicDesign.where(name: data["name"]).update_all(
        mosaic_series_id: series.id,
        collection_position: data["collection_position"]
      )
    end

    missing_names = MosaicDesign.where(mosaic_series_id: nil).pluck(:name)
    return if missing_names.empty?

    raise "シリーズ未設定の題材があります: #{missing_names.join(', ')}"
  end

  def series_rows
    YAML.safe_load_file(Rails.root.join("db/seed_data/mosaic_designs/series.yml"))
  end
end
