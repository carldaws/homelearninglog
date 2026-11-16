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

ActiveRecord::Schema[8.1].define(version: 2026_11_16_213000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accesses", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id", "user_id"], name: "index_accesses_on_child_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_accesses_on_user_id"
  end

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
    t.string "name", null: false
    t.string "calendar_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_token"], name: "index_children_on_calendar_token", unique: true
  end

  create_table "children_invitations", id: false, force: :cascade do |t|
    t.bigint "child_id", null: false
    t.bigint "invitation_id", null: false
    t.index ["child_id"], name: "index_children_invitations_on_child_id"
    t.index ["invitation_id", "child_id"], name: "index_children_invitations_on_invitation_id_and_child_id", unique: true
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.bigint "author_id", null: false
    t.date "happened_on", null: false
    t.text "what_we_did"
    t.text "what_was_learned"
    t.integer "minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id"
    t.index ["author_id"], name: "index_entries_on_author_id"
    t.index ["child_id", "happened_on"], name: "index_entries_on_child_id_and_happened_on"
    t.index ["event_id"], name: "index_entries_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "child_id", null: false
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
    t.index ["child_id"], name: "index_events_on_child_id"
    t.index ["grown_up_id"], name: "index_events_on_grown_up_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.bigint "entry_id", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_ideas_on_entry_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "inviter_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
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

  add_foreign_key "accesses", "children"
  add_foreign_key "accesses", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cancellations", "events"
  add_foreign_key "children_invitations", "children"
  add_foreign_key "children_invitations", "invitations"
  add_foreign_key "entries", "children"
  add_foreign_key "entries", "events"
  add_foreign_key "entries", "users", column: "author_id"
  add_foreign_key "events", "children"
  add_foreign_key "events", "users", column: "grown_up_id"
  add_foreign_key "ideas", "entries"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "sessions", "users"
end
