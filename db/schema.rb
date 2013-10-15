# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131015221924) do

  create_table "chefs", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "abbreviation"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "chefs", ["abbreviation"], :name => "chefs_abbr_uq", :unique => true
  add_index "chefs", ["first_name", "last_name"], :name => "chefs_name_uq", :unique => true

  create_table "chefs_users", :id => false, :force => true do |t|
    t.integer "chef_id", :null => false
    t.integer "user_id", :null => false
  end

  add_index "chefs_users", ["chef_id", "user_id"], :name => "index_chefs_users_on_chef_id_and_user_id", :unique => true

  create_table "chefstats", :force => true do |t|
    t.integer  "chef_id"
    t.integer  "stat_id"
    t.integer  "week"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "chefstats", ["chef_id"], :name => "index_chefstats_on_chef_id"
  add_index "chefstats", ["stat_id", "chef_id", "week"], :name => "index_chefstats_on_stat_id_and_chef_id_and_week", :unique => true
  add_index "chefstats", ["stat_id"], :name => "index_chefstats_on_stat_id"

  create_table "draft_picks", :force => true do |t|
    t.string   "league"
    t.integer  "round"
    t.integer  "pick"
    t.integer  "user_id"
    t.integer  "chef_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "draft_picks", ["chef_id"], :name => "index_draft_picks_on_chef_id"
  add_index "draft_picks", ["user_id"], :name => "index_draft_picks_on_user_id"

  create_table "picks", :force => true do |t|
    t.integer  "week"
    t.integer  "number"
    t.integer  "user_id"
    t.integer  "chef_id"
    t.string   "record"
    t.integer  "points"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "picks", ["chef_id"], :name => "index_picks_on_chef_id"
  add_index "picks", ["user_id"], :name => "index_picks_on_user_id"
  add_index "picks", ["week", "chef_id", "record"], :name => "picks_week_chef_record_uq", :unique => true
  add_index "picks", ["week", "number"], :name => "picks_week_num_uq", :unique => true
  add_index "picks", ["week", "user_id", "record"], :name => "picks_week_user_record_uq", :unique => true

  create_table "stats", :force => true do |t|
    t.string   "name"
    t.integer  "points"
    t.string   "abbreviation"
    t.string   "short_name"
    t.integer  "ordinal"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "auth_token"
    t.string   "role"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "weeks", :force => true do |t|
    t.integer  "number"
    t.datetime "start_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "weeks", ["number"], :name => "weeks_number_uq", :unique => true
  add_index "weeks", ["start_time"], :name => "weeks_start_time_uq", :unique => true

end
