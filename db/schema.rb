# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_24_194340) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.boolean "supply_center", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "coast_id"
    t.index ["coast_id"], name: "index_areas_on_coast_id"
  end

  create_table "coasts", force: :cascade do |t|
    t.string "direction", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "neighbors", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "area_id"
    t.string "neighbor_type"
    t.bigint "neighbor_id"
    t.index ["area_id"], name: "index_neighbors_on_area_id"
    t.index ["neighbor_type", "neighbor_id"], name: "index_neighbors_on_neighbor_type_and_neighbor_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_game_id"
    t.bigint "turn_id"
    t.bigint "position_id"
    t.bigint "from_id"
    t.bigint "to_id"
    t.index ["from_id"], name: "index_orders_on_from_id"
    t.index ["position_id"], name: "index_orders_on_position_id"
    t.index ["to_id"], name: "index_orders_on_to_id"
    t.index ["turn_id"], name: "index_orders_on_turn_id"
    t.index ["user_game_id"], name: "index_orders_on_user_game_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "area_id"
    t.bigint "coast_id"
    t.bigint "user_game_id"
    t.index ["area_id"], name: "index_positions_on_area_id"
    t.index ["coast_id"], name: "index_positions_on_coast_id"
    t.index ["user_game_id"], name: "index_positions_on_user_game_id"
  end

  create_table "turns", force: :cascade do |t|
    t.string "type", null: false
    t.integer "number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "game_id"
    t.index ["game_id"], name: "index_turns_on_game_id"
  end

  create_table "user_games", force: :cascade do |t|
    t.string "power", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "game_id"
    t.bigint "user_id"
    t.index ["game_id"], name: "index_user_games_on_game_id"
    t.index ["user_id"], name: "index_user_games_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "areas", "coasts"
  add_foreign_key "neighbors", "areas"
  add_foreign_key "orders", "areas", column: "from_id"
  add_foreign_key "orders", "areas", column: "to_id"
  add_foreign_key "orders", "positions"
  add_foreign_key "orders", "turns"
  add_foreign_key "orders", "user_games"
  add_foreign_key "positions", "areas"
  add_foreign_key "positions", "coasts"
  add_foreign_key "positions", "user_games"
  add_foreign_key "turns", "games"
  add_foreign_key "user_games", "games"
  add_foreign_key "user_games", "users"
end
