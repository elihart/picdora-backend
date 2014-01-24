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

ActiveRecord::Schema.define(version: 20140124185439) do

  create_table "albums", force: true do |t|
    t.boolean  "nsfw",         default: false
    t.integer  "reddit_score"
    t.integer  "category_id"
    t.string   "imgurId"
    t.boolean  "deleted",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "anon_users", force: true do |t|
    t.string   "device"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.boolean  "nsfw",       default: false
    t.boolean  "porn",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: true do |t|
    t.string   "imgurId"
    t.integer  "reddit_score"
    t.boolean  "reported",     default: false
    t.boolean  "nsfw",         default: false
    t.boolean  "gif",          default: false
    t.integer  "category_id"
    t.integer  "album_id"
    t.boolean  "landscape"
    t.boolean  "deleted",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
