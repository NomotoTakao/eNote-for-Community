class CreateMPlaces < ActiveRecord::Migration
  def self.up
    create_table "m_places", :force => true do |t|
      t.string   "place_cd",    :limit => 16,                                                  :null => false
      t.integer  "sort_no",                                                   :default => 1
      t.string   "name",        :limit => 80
      t.string   "zip_cd",      :limit => 8
      t.string   "address1",    :limit => 60
      t.string   "address2",    :limit => 60
      t.text     "address3"
      t.text     "memo"
      t.integer  "etcint1",                                                   :default => 0
      t.integer  "etcint2",                                                   :default => 0
      t.integer  "etcdec1",     :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",     :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",     :limit => 200
      t.string   "etcstr2",     :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",        :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd", :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd", :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd", :limit => 32
      t.datetime "updated_at"
    end

    add_index "m_places", ["place_cd"], :name => "idx_m_places_1"  end

  def self.down
    drop_table :m_places
  end
end
