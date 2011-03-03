# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110303172023) do

  create_table "acknowledgments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "body"
    t.string   "uid"
    t.string   "to"
    t.string   "status"
    t.string   "from"
    t.integer  "notification_id"
  end

  create_table "channels", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mechanism_id"
    t.integer  "contact_id"
    t.string   "address"
    t.boolean  "enabled"
    t.integer  "time_window_id"
  end

  create_table "conduits", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "server"
    t.integer  "port"
    t.string   "username"
    t.string   "password"
    t.boolean  "encryption"
    t.integer  "handler_id"
  end

  create_table "contacts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "last_name"
    t.string   "first_name"
    t.boolean  "enabled"
  end

  create_table "groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "description"
    t.boolean  "enabled"
  end

  create_table "handlers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "designation"
  end

  create_table "keywords", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "designation"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "parent_id"
    t.integer  "time_window_id"
  end

  create_table "mechanisms", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "designation"
  end

  create_table "memberships", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contact_id"
    t.integer  "group_id"
  end

  create_table "messages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid"
    t.string   "sender"
    t.string   "recipients_direct"
    t.string   "recipients_indirect"
    t.datetime "stamp"
    t.string   "subject"
    t.text     "body"
    t.text     "keywords"
    t.string   "state",               :default => "received"
    t.string   "importance"
  end

  create_table "notifications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sender"
    t.string   "subject"
    t.text     "body"
    t.integer  "importance"
    t.integer  "message_id"
    t.text     "keywords"
    t.integer  "channel_id"
    t.string   "state",      :default => "created"
    t.string   "code"
    t.string   "uid"
  end

  create_table "patterns", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "definition"
    t.integer  "contact_id"
    t.boolean  "active"
    t.string   "duration"
  end

  create_table "schedules", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contact_id",     :limit => 10, :precision => 10, :scale => 0
    t.integer  "time_window_id", :limit => 10, :precision => 10, :scale => 0
  end

  create_table "states", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "designation"
  end

  create_table "subscriptions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contact_id"
    t.integer  "keyword_id"
  end

  create_table "time_windows", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "definition"
    t.string   "description"
    t.boolean  "active"
  end

end
