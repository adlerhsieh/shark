# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180217031754) do

  create_table "fx_signals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "source_id"
    t.string "source_type"
    t.integer "pair_id"
    t.string "direction"
    t.decimal "entry", precision: 10, scale: 5
    t.decimal "take_profit", precision: 10, scale: 5
    t.decimal "stop_loss", precision: 10, scale: 5
    t.datetime "opened_at"
    t.decimal "closed", precision: 10, scale: 5
    t.datetime "closed_at"
    t.text "raw"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pair_id"], name: "index_fx_signals_on_pair_id"
    t.index ["source_id"], name: "index_fx_signals_on_source_id"
    t.index ["source_type"], name: "index_fx_signals_on_source_type"
  end

  create_table "pairs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "base"
    t.string "quote"
    t.boolean "mini"
    t.string "ig_epic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
