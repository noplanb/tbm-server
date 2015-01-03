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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150102214612) do

  create_table "connections", force: true do |t|
    t.integer  "creator_id"
    t.integer  "target_id"
    t.string   "status"
    t.string   "connection_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["connection_key"], name: "index_connections_on_connection_key", using: :btree
  add_index "connections", ["creator_id"], name: "index_connections_on_creator_id", using: :btree
  add_index "connections", ["target_id"], name: "index_connections_on_target_id", using: :btree

  create_table "kvstores", force: true do |t|
    t.string   "key1"
    t.string   "key2"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kvstores", ["key1"], name: "index_kvstores_on_key1", using: :btree

  create_table "push_users", force: true do |t|
    t.string   "mkey"
    t.string   "push_token"
    t.string   "device_platform"
    t.string   "device_build"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "push_users", ["mkey"], name: "index_push_users_on_mkey", using: :btree

  create_table "s3_infos", force: true do |t|
    t.string   "region"
    t.string   "bucket"
    t.string   "access_key"
    t.string   "secret_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "mobile_number"
    t.string   "email"
    t.string   "user_name"
    t.string   "device_platform"
    t.string   "auth"
    t.string   "mkey"
    t.string   "verification_code"
    t.datetime "verification_date_time"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["mkey"], name: "index_users_on_mkey", using: :btree
  add_index "users", ["mobile_number"], name: "index_users_on_mobile_number", using: :btree

  create_table "videos", force: true do |t|
    t.string   "filename"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "videos", ["filename"], name: "index_videos_on_filename", using: :btree

end
