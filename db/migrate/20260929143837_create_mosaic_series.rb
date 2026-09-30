class CreateMosaicSeries < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    unless table_exists?(:mosaic_series)
      create_table :mosaic_series do |t|
        t.string :name, null: false
        t.integer :position, null: false
        t.timestamps
      end
    end

    add_index :mosaic_series, :name, unique: true, if_not_exists: true
    add_index :mosaic_series, :position, unique: true, if_not_exists: true

    add_column :mosaic_designs, :mosaic_series_id, :bigint, if_not_exists: true
    add_index :mosaic_designs, :mosaic_series_id, if_not_exists: true
    add_foreign_key :mosaic_designs, :mosaic_series,
                    column: :mosaic_series_id, if_not_exists: true
    add_column :mosaic_designs, :collection_position, :integer, if_not_exists: true

    backfill_from_yaml!

    add_index :mosaic_designs, [ :mosaic_series_id, :collection_position ],
              unique: true, if_not_exists: true,
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
    now = Time.current
    series_id_by_name = {}

    series_rows.each do |row|
      name = row["name"]
      position = row["position"].to_i
      series_id_by_name[name] = select_value(<<~SQL.squish)
        INSERT INTO mosaic_series (name, position, created_at, updated_at)
        VALUES (#{connection.quote(name)}, #{position}, #{connection.quote(now)}, #{connection.quote(now)})
        ON CONFLICT (name) DO UPDATE SET position = EXCLUDED.position
        RETURNING id
      SQL
    end

    Dir.glob(Rails.root.join("db/seed_data/mosaic_designs/colors/*.yml")).each do |yaml_path|
      data = YAML.safe_load_file(yaml_path, permitted_classes: [ Symbol ], aliases: true)
      series_id = series_id_by_name[data["series_name"]]
      raise "未知のシリーズです: #{data["series_name"]} (#{yaml_path})" if series_id.nil?

      execute(<<~SQL.squish)
        UPDATE mosaic_designs
        SET mosaic_series_id = #{series_id.to_i},
            collection_position = #{data["collection_position"].to_i}
        WHERE name = #{connection.quote(data["name"])}
      SQL
    end

    missing_names = select_values("SELECT name FROM mosaic_designs WHERE mosaic_series_id IS NULL")
    return if missing_names.empty?

    say "カタログ外の題材は住所なしのままにします: #{missing_names.join(", ")}"
  end

  def series_rows
    YAML.safe_load_file(Rails.root.join("db/seed_data/mosaic_designs/series.yml"))
  end
end
