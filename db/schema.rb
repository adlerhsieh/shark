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

ActiveRecord::Schema.define(version: 20180331083838) do

  create_table "audit_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "source_type"
    t.integer "source_id"
    t.string "event"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id"], name: "index_audit_logs_on_source_id"
    t.index ["source_type"], name: "index_audit_logs_on_source_type"
  end

  create_table "blacklist_emails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "source"
    t.string "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source"], name: "index_blacklist_emails_on_source"
    t.index ["source_id"], name: "index_blacklist_emails_on_source_id"
  end

  create_table "fx_signals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "source_id"
    t.integer "pair_id"
    t.string "direction"
    t.decimal "entry", precision: 10, scale: 5
    t.decimal "take_profit", precision: 10, scale: 5
    t.decimal "stop_loss", precision: 10, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "evaluated_at"
    t.datetime "terminated_at"
    t.string "source_secondary_id"
    t.string "source_ref", limit: 800
    t.datetime "expired_at"
    t.boolean "issue", default: false
    t.decimal "confidence", precision: 10, scale: 5
    t.string "target_resource"
    t.string "action"
    t.index ["created_at"], name: "index_fx_signals_on_created_at"
    t.index ["pair_id"], name: "index_fx_signals_on_pair_id"
    t.index ["source_id"], name: "index_fx_signals_on_source_id"
    t.index ["source_secondary_id"], name: "index_fx_signals_on_source_secondary_id"
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "pair_id"
    t.string "ig_deal_id"
    t.string "direction"
    t.decimal "size", precision: 10, scale: 5
    t.decimal "entry", precision: 10, scale: 5
    t.decimal "take_profit", precision: 10, scale: 5
    t.decimal "stop_loss", precision: 10, scale: 5
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ig_deal_reference"
    t.string "ig_status"
    t.boolean "deleted", default: false
    t.integer "source_id"
    t.integer "signal_id"
    t.boolean "issue", default: false
    t.index ["deleted"], name: "index_orders_on_deleted"
    t.index ["ig_deal_id"], name: "index_orders_on_ig_deal_id"
    t.index ["pair_id"], name: "index_orders_on_pair_id"
    t.index ["signal_id"], name: "index_orders_on_signal_id"
    t.index ["source_id"], name: "index_orders_on_source_id"
  end

  create_table "pairs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "base"
    t.string "quote"
    t.boolean "mini"
    t.string "ig_epic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "forex_category"
    t.index ["forex_category"], name: "index_pairs_on_forex_category"
  end

  create_table "positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "pair_id"
    t.string "ig_deal_id"
    t.string "direction"
    t.decimal "entry", precision: 10, scale: 5
    t.decimal "size", precision: 10, scale: 5
    t.decimal "take_profit", precision: 10, scale: 5
    t.decimal "stop_loss", precision: 10, scale: 5
    t.datetime "opened_at"
    t.decimal "closed", precision: 10, scale: 5
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_id"
    t.string "ig_deal_reference"
    t.string "ig_status"
    t.integer "signal_id"
    t.decimal "pl", precision: 10, scale: 5
    t.string "currency"
    t.integer "order_id"
    t.boolean "issue", default: false
    t.index ["ig_deal_id"], name: "index_positions_on_ig_deal_id"
    t.index ["order_id"], name: "index_positions_on_order_id"
    t.index ["pair_id"], name: "index_positions_on_pair_id"
    t.index ["signal_id"], name: "index_positions_on_signal_id"
    t.index ["source_id"], name: "index_positions_on_source_id"
  end

  create_table "sources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.string "abbreviation"
  end

  create_table "tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scope"
    t.index ["name"], name: "index_tokens_on_name"
    t.index ["scope"], name: "index_tokens_on_scope"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "locked_at"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
