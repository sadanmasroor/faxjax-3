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

ActiveRecord::Schema.define(:version => 0) do

  create_table "application_configs", :force => true do |t|
    t.string  "admin_password"
    t.integer "session_timeout_minutes", :default => 15, :null => false
  end

  create_table "categories", :force => true do |t|
    t.integer "parent_id"
    t.string  "name",               :default => "",   :null => false
    t.boolean "allow_listings",     :default => true
    t.integer "status",             :default => 0,    :null => false
    t.text    "excluded_field_ids"
  end

  add_index "categories", ["parent_id"], :name => "fk_category"

  create_table "contacts", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "email_1"
    t.string   "email_2"
    t.string   "promo_code"
    t.datetime "created_on"
    t.datetime "updated_at"
  end

  create_table "field_groups", :force => true do |t|
    t.integer "category_id"
    t.string  "name"
    t.integer "position"
  end

  add_index "field_groups", ["category_id"], :name => "fk_field_group2category"

  create_table "field_values", :force => true do |t|
    t.integer "field_id", :default => 0,  :null => false
    t.string  "value",    :default => "", :null => false
  end

  add_index "field_values", ["field_id"], :name => "fk_field_values2field"

  create_table "help_topics", :force => true do |t|
    t.string "title"
    t.text   "content"
  end

  create_table "invoice_details", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "sign_product_id"
    t.integer  "qty"
    t.integer  "discount"
    t.datetime "uptated_at"
    t.datetime "created_on"
  end

  create_table "invoices", :force => true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "email"
    t.integer  "shipping"
    t.integer  "discount"
    t.integer  "tax"
    t.integer  "total"
    t.string   "promo_code"
    t.string   "affiliate_code"
    t.datetime "updated_at"
    t.datetime "created_on"
  end

  create_table "listing_values", :force => true do |t|
    t.integer "listing_id", :default => 0, :null => false
    t.integer "field_id",   :default => 0, :null => false
    t.string  "value"
  end

  add_index "listing_values", ["field_id"], :name => "field_id"
  add_index "listing_values", ["listing_id"], :name => "listing_id"

  create_table "listings", :force => true do |t|
    t.integer  "category_id",               :default => 0,     :null => false
    t.integer  "sign_id"
    t.integer  "user_id",                   :default => 0,     :null => false
    t.string   "name",                      :default => "",    :null => false
    t.text     "description"
    t.integer  "price",                     :default => 0,     :null => false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.datetime "expires_on",                                   :null => false
    t.string   "sign_code"
    t.text     "extra_values"
    t.string   "city"
    t.string   "state",        :limit => 2
    t.integer  "zip_code",                                     :null => false
    t.integer  "negotiable"
    t.integer  "hits",                      :default => 0,     :null => false
    t.text     "url_1"
    t.text     "url_2"
    t.boolean  "featured",                  :default => false, :null => false
  end

  add_index "listings", ["description", "extra_values"], :name => "listings_fulltext"

  create_table "messages", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "user_id"
    t.integer  "from_user_id"
    t.datetime "created_on"
    t.datetime "read_on"
    t.string   "subject"
    t.text     "message"
    t.datetime "deleted_on"
    t.string   "from_email"
  end

  create_table "nonce_stores", :force => true do |t|
    t.string   "value",      :limit => 128,                   :null => false
    t.boolean  "active",                    :default => true
    t.integer  "foreign_id"
    t.string   "model_name"
    t.datetime "created_on"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "vendor_id"
    t.integer  "status",      :default => 0, :null => false
    t.datetime "created_on"
    t.datetime "billed_on"
    t.datetime "paid_on"
    t.datetime "canceled_on"
    t.string   "promo_code"
  end

  create_table "promo_codes", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.text     "description"
    t.datetime "start"
    t.datetime "finish"
    t.integer  "discount_pct"
    t.integer  "discount_flat"
    t.integer  "rebate_flat"
    t.integer  "rebate_pct"
    t.datetime "created_on"
    t.datetime "updated_at"
  end

  create_table "schema_info", :id => false, :force => true do |t|
    t.integer "version"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "sign_lots", :force => true do |t|
    t.string  "order_id"
    t.integer "quantity",        :default => 0, :null => false
    t.integer "price",           :default => 0, :null => false
    t.integer "sign_product_id"
    t.string  "name"
  end

  create_table "sign_lots_signs", :id => false, :force => true do |t|
    t.integer "sign_lot_id"
    t.integer "sign_id"
  end

  create_table "sign_products", :force => true do |t|
    t.string  "title",          :default => "", :null => false
    t.text    "description",                    :null => false
    t.string  "sign_type"
    t.integer "sign_duration"
    t.integer "price",          :default => 0,  :null => false
    t.integer "deleted",        :default => 0
    t.integer "shipping_price"
    t.integer "tax"
  end

  create_table "signs", :force => true do |t|
    t.string   "code",            :default => "", :null => false
    t.string   "key",             :default => "", :null => false
    t.datetime "activated_on"
    t.integer  "user_id"
    t.integer  "vendor_id"
    t.integer  "listing_id"
    t.datetime "updated_on"
    t.integer  "duration"
    t.integer  "sign_product_id"
    t.string   "type"
  end

  add_index "signs", ["code"], :name => "sign_code"

  create_table "the_fields", :force => true do |t|
    t.integer "category_id",                  :default => 0,     :null => false
    t.integer "field_group_id"
    t.string  "name",                         :default => "",    :null => false
    t.integer "position",                     :default => 0,     :null => false
    t.boolean "required",                     :default => false, :null => false
    t.boolean "numeric",                      :default => false, :null => false
    t.string  "type",           :limit => 24
    t.integer "maximum"
  end

  add_index "the_fields", ["category_id"], :name => "fk_field2category"
  add_index "the_fields", ["field_group_id"], :name => "fk_field2field_group"

  create_table "trackings", :force => true do |t|
    t.string   "name"
    t.string   "source"
    t.string   "ip_address"
    t.datetime "created_on"
    t.datetime "updated_at"
  end

  create_table "user_prefs", :force => true do |t|
    t.boolean "welcome_message",            :default => true, :null => false
    t.boolean "helper_home_search",         :default => true, :null => false
    t.boolean "helper_home_activation",     :default => true, :null => false
    t.boolean "notify_on_message_received"
    t.integer "user_id"
    t.boolean "send_promotions"
  end

  create_table "users", :force => true do |t|
    t.string   "type",         :limit => 24
    t.string   "name",                       :default => "", :null => false
    t.string   "first_name",                 :default => "", :null => false
    t.string   "last_name",                  :default => "", :null => false
    t.string   "email"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "password"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.boolean  "has_read_tos"
    t.string   "salt",         :limit => 65
    t.string   "hashed_link",  :limit => 48
  end

  create_table "vendors", :force => true do |t|
    t.integer "status",             :default => 0, :null => false
    t.string  "username"
    t.string  "password"
    t.string  "name"
    t.string  "contact_first_name"
    t.string  "contact_last_name"
    t.string  "contact_email"
    t.string  "address"
    t.string  "address2"
    t.string  "city"
    t.string  "state"
    t.integer "zip"
    t.string  "phone"
    t.string  "url"
  end

  create_table "videos", :force => true do |t|
    t.string "title"
    t.string "embed_code"
  end

end
