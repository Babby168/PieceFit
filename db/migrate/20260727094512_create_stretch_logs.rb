class CreateStretchLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :stretch_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stretch, null: false, foreign_key: true
      t.datetime :performed_at, null: false

      t.timestamps
    end
  end
end
