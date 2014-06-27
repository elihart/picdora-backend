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

ActiveRecord::Schema.define(version: 20140531001410) do

  create_table "albums", force: true do |t|
    t.boolean  "nsfw",         default: false
    t.integer  "reddit_score"
    t.string   "imgurId"
    t.boolean  "deleted",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albums_categories", id: false, force: true do |t|
    t.integer "category_id"
    t.integer "album_id"
  end

  add_index "albums_categories", ["category_id", "album_id"], name: "by_album_and_category", unique: true

  create_table "categories", force: true do |t|
    t.string   "name"
    t.boolean  "nsfw",               default: false
    t.string   "icon"
    t.string   "reddit_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "category_name_ix"

  create_table "categories_images", id: false, force: true do |t|
    t.integer "category_id"
    t.integer "image_id"
  end

  add_index "categories_images", ["category_id", "image_id"], name: "by_image_and_category", unique: true

  create_table "image_update_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "image_id"
    t.boolean  "deleted",    default: false
    t.boolean  "reported",   default: false
    t.boolean  "gif",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: true do |t|
    t.string   "imgurId"
    t.integer  "reddit_score"
    t.boolean  "reported",     default: false
    t.boolean  "nsfw",         default: false
    t.boolean  "gif",          default: false
    t.integer  "album_id"
    t.boolean  "deleted",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logins", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "device_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
