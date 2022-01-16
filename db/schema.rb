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

ActiveRecord::Schema.define(version: 2022_01_16_024507) do

  create_table "settings", force: :cascade do |t|
    t.float "static_temp_factor"
    t.float "dynamic_temp_factor"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "max_rate_adjustment_delta"
  end

  create_table "temp_monitors", force: :cascade do |t|
    t.float "upper_limitf"
    t.float "lower_limitf"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_fired_at", precision: 6
    t.string "title"
    t.boolean "send_notifications"
    t.boolean "toggle_fan"
    t.boolean "enabled"
    t.string "reading_location"
  end

  create_table "temp_readings", force: :cascade do |t|
    t.float "tempf"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "raw_tempf"
    t.float "confirmed_tempf"
  end

end
