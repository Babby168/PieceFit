# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_11_052943) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "design_pieces", force: :cascade do |t|
    t.string "color", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.bigint "mosaic_design_id", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["mosaic_design_id"], name: "index_design_pieces_on_mosaic_design_id"
  end

  create_table "mosaic_arts", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "mosaic_design_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["mosaic_design_id"], name: "index_mosaic_arts_on_mosaic_design_id"
    t.index ["user_id"], name: "index_mosaic_arts_on_user_id"
  end

  create_table "mosaic_designs", force: :cascade do |t|
    t.integer "area_size_x", default: 10, null: false
    t.integer "area_size_y", default: 9, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pieces", force: :cascade do |t|
    t.datetime "acquired_at"
    t.datetime "created_at", null: false
    t.boolean "is_bonus", default: false, null: false
    t.bigint "mosaic_art_id", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["mosaic_art_id", "position"], name: "index_pieces_on_mosaic_art_id_and_position", unique: true
    t.index ["mosaic_art_id"], name: "index_pieces_on_mosaic_art_id"
  end

  create_table "stretch_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "performed_at", null: false
    t.bigint "stretch_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["stretch_id"], name: "index_stretch_logs_on_stretch_id"
    t.index ["user_id"], name: "index_stretch_logs_on_user_id"
  end

  create_table "stretch_steps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "image_path", null: false
    t.integer "step_number", null: false
    t.bigint "stretch_id", null: false
    t.datetime "updated_at", null: false
    t.index ["stretch_id", "step_number"], name: "index_stretch_steps_on_stretch_id_and_step_number", unique: true
    t.index ["stretch_id"], name: "index_stretch_steps_on_stretch_id"
  end

  create_table "stretches", force: :cascade do |t|
    t.integer "body_part", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "key_visual_path"
    t.string "name", null: false
    t.string "point"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "email_change_token"
    t.datetime "email_change_token_sent_at"
    t.string "encrypted_password", default: "", null: false
    t.string "nickname", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_change_token"], name: "index_users_on_email_change_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "design_pieces", "mosaic_designs"
  add_foreign_key "mosaic_arts", "mosaic_designs"
  add_foreign_key "mosaic_arts", "users"
  add_foreign_key "pieces", "mosaic_arts"
  add_foreign_key "stretch_logs", "stretches"
  add_foreign_key "stretch_logs", "users"
  add_foreign_key "stretch_steps", "stretches"
end
