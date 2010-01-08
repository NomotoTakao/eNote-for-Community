class Sessions < ActiveRecord::Migration
  def self.up
    create_table "sessions", :force => true do |t|
      t.string   "session_id"
      t.text     "data"
      t.string   "user_id",       :limit => 32
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  end

  def self.down
    drop_table :sessions
  end
end
