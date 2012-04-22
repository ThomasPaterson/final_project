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

ActiveRecord::Schema.define(:version => 20120410014114) do

  create_table "dashboards", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "poster_id"
    t.boolean  "all_day"
    t.boolean  "is_public"
    t.boolean  "confirmed"
  end

  create_table "items", :force => true do |t|
    t.text     "content"
    t.integer  "list_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "poster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content"
    t.integer  "parent_id"
  end

  create_table "posts", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "dashboard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_to"
    t.boolean  "is_private"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "reminders", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "user_id"
    t.integer  "poster_id"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  add_index "reminders", ["time"], :name => "index_reminders_on_time"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["event_id"], :name => "index_tags_on_event_id"
  add_index "tags", ["item_id"], :name => "index_tags_on_item_id"
  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "permission_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "time_zone"
    t.string   "fname"
    t.string   "lname"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
