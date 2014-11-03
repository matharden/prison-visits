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

ActiveRecord::Schema.define(version: 20141103120239) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "visit_metrics_entries", force: true do |t|
    t.string   "visit_id"
    t.string   "prison_name"
    t.datetime "requested_at"
    t.datetime "opened_at"
    t.datetime "processed_at"
    t.string   "outcome"
    t.string   "reason"
    t.integer  "processing_time"
    t.integer  "end_to_end_time"
  end

  add_index "visit_metrics_entries", ["end_to_end_time", "requested_at", "processed_at"], name: "visit_metrics_entries_end_to_end_time_requested_at_processe_idx", using: :btree
  add_index "visit_metrics_entries", ["prison_name"], name: "index_visit_metrics_entries_on_prison_name", using: :btree
  add_index "visit_metrics_entries", ["requested_at", "processed_at"], name: "index_visit_metrics_entries_on_requested_at_and_processed_at", using: :btree
  add_index "visit_metrics_entries", ["visit_id"], name: "index_visit_metrics_entries_on_visit_id", unique: true, using: :btree

end
