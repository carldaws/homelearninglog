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

ActiveRecord::Schema[8.1].define(version: 2026_11_16_172833) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cancellations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.date "cancelled_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "cancelled_on"], name: "index_cancellations_on_event_id_and_cancelled_on", unique: true
  end

  create_table "children", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_children_on_family_id"
  end

  create_table "children_entries", id: false, force: :cascade do |t|
    t.bigint "child_id", null: false
    t.bigint "entry_id", null: false
    t.index ["child_id"], name: "index_children_entries_on_child_id"
    t.index ["entry_id", "child_id"], name: "index_children_entries_on_entry_id_and_child_id", unique: true
  end

  create_table "children_events", id: false, force: :cascade do |t|
    t.bigint "child_id", null: false
    t.bigint "event_id", null: false
    t.index ["child_id"], name: "index_children_events_on_child_id"
    t.index ["event_id", "child_id"], name: "index_children_events_on_event_id_and_child_id", unique: true
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "author_id", null: false
    t.date "happened_on", null: false
    t.text "notes"
    t.integer "minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id"
    t.index ["author_id"], name: "index_entries_on_author_id"
    t.index ["event_id"], name: "index_entries_on_event_id"
    t.index ["family_id", "happened_on"], name: "index_entries_on_family_id_and_happened_on"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "grown_up_id"
    t.string "title", null: false
    t.date "starts_on", null: false
    t.time "start_time"
    t.time "end_time"
    t.integer "repeats", default: 0, null: false
    t.date "repeats_until"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_events_on_family_id"
    t.index ["grown_up_id"], name: "index_events_on_grown_up_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name", null: false
    t.string "invitation_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "calendar_token", null: false
    t.index ["calendar_token"], name: "index_families_on_calendar_token", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_memberships_on_family_id"
    t.index ["user_id"], name: "index_memberships_on_user_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "recovery_code_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cancellations", "events"
  add_foreign_key "children", "families"
  add_foreign_key "children_entries", "children"
  add_foreign_key "children_entries", "entries"
  add_foreign_key "children_events", "children"
  add_foreign_key "children_events", "events"
  add_foreign_key "entries", "events"
  add_foreign_key "entries", "families"
  add_foreign_key "entries", "users", column: "author_id"
  add_foreign_key "events", "families"
  add_foreign_key "events", "users", column: "grown_up_id"
  add_foreign_key "memberships", "families"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
end
