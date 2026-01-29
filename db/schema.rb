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

ActiveRecord::Schema[8.0].define(version: 2026_01_29_195438) do
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

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "model_id"
    t.index ["model_id"], name: "index_chats_on_model_id"
  end

  create_table "coffee_bean_rotations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "coffee_bean_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coffee_bean_id"], name: "index_coffee_bean_rotations_on_coffee_bean_id"
    t.index ["user_id", "coffee_bean_id"], name: "index_coffee_bean_rotations_on_user_id_and_coffee_bean_id", unique: true
    t.index ["user_id"], name: "index_coffee_bean_rotations_on_user_id"
  end

  create_table "coffee_beans", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "brand"
    t.string "origin"
    t.json "variety", default: []
    t.json "process", default: []
    t.json "tasting_notes", default: []
    t.string "producer"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false, null: false
    t.string "slug"
    t.index ["slug"], name: "index_coffee_beans_on_slug", unique: true
    t.index ["user_id"], name: "index_coffee_beans_on_user_id"
  end

  create_table "favorite_coffee_beans", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "coffee_bean_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coffee_bean_id"], name: "index_favorite_coffee_beans_on_coffee_bean_id"
    t.index ["user_id", "coffee_bean_id"], name: "index_favorite_coffee_beans_on_user_id_and_coffee_bean_id", unique: true
    t.index ["user_id"], name: "index_favorite_coffee_beans_on_user_id"
  end

  create_table "favorite_recipes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_favorite_recipes_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_favorite_recipes_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_favorite_recipes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "role", null: false
    t.text "content"
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chat_id", null: false
    t.integer "model_id"
    t.integer "tool_call_id"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["model_id"], name: "index_messages_on_model_id"
    t.index ["role"], name: "index_messages_on_role"
    t.index ["tool_call_id"], name: "index_messages_on_tool_call_id"
  end

  create_table "models", force: :cascade do |t|
    t.string "model_id", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "family"
    t.datetime "model_created_at"
    t.integer "context_window"
    t.integer "max_output_tokens"
    t.date "knowledge_cutoff"
    t.json "modalities", default: {}
    t.json "capabilities", default: []
    t.json "pricing", default: {}
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family"], name: "index_models_on_family"
    t.index ["provider", "model_id"], name: "index_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_models_on_provider"
  end

  create_table "recipe_comments", force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "user_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published"
    t.index ["recipe_id"], name: "index_recipe_comments_on_recipe_id"
    t.index ["user_id"], name: "index_recipe_comments_on_user_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.integer "coffee_bean_id", null: false
    t.string "recipe_type", null: false
    t.string "name"
    t.text "description"
    t.string "grind_size"
    t.decimal "coffee_weight", precision: 8, scale: 2
    t.decimal "water_weight", precision: 8, scale: 2
    t.decimal "water_temperature", precision: 5, scale: 2
    t.boolean "inverted_method"
    t.json "steps"
    t.text "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_recipe_id"
    t.boolean "published", default: false, null: false
    t.string "slug"
    t.index ["coffee_bean_id"], name: "index_recipes_on_coffee_bean_id"
    t.index ["recipe_type"], name: "index_recipes_on_recipe_type"
    t.index ["slug"], name: "index_recipes_on_slug", unique: true
    t.index ["source_recipe_id"], name: "index_recipes_on_source_recipe_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tool_calls", force: :cascade do |t|
    t.string "tool_call_id", null: false
    t.string "name", null: false
    t.json "arguments", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "message_id", null: false
    t.index ["message_id"], name: "index_tool_calls_on_message_id"
    t.index ["name"], name: "index_tool_calls_on_name"
    t.index ["tool_call_id"], name: "index_tool_calls_on_tool_call_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chats", "models"
  add_foreign_key "coffee_bean_rotations", "coffee_beans"
  add_foreign_key "coffee_bean_rotations", "users"
  add_foreign_key "coffee_beans", "users"
  add_foreign_key "favorite_coffee_beans", "coffee_beans"
  add_foreign_key "favorite_coffee_beans", "users"
  add_foreign_key "favorite_recipes", "recipes"
  add_foreign_key "favorite_recipes", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "messages", "models"
  add_foreign_key "messages", "tool_calls"
  add_foreign_key "recipe_comments", "recipes"
  add_foreign_key "recipe_comments", "users"
  add_foreign_key "recipes", "coffee_beans"
  add_foreign_key "recipes", "recipes", column: "source_recipe_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "tool_calls", "messages"
end
