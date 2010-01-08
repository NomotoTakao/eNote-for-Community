class CreateDCabinetIndices < ActiveRecord::Migration
  def self.up
    create_table "d_cabinet_indices", :force => true do |t|
      t.integer  "cabinet_kbn",            :limit => 2,                                  :default => 0, :null => false
      t.string   "index_type",                   :limit => 1
      t.integer  "parent_cabinet_head_id",                                               :default => 0, :null => false
      t.integer  "d_cabinet_head_id",                                                                   :null => false
      t.string   "title",                  :limit => 40
      t.string   "disp_org_cd",            :limit => 9
      t.integer  "order_display",                                                        :default => 0
      t.integer  "etcint1",                                                              :default => 0
      t.integer  "etcint2",                                                              :default => 0
      t.integer  "etcdec1",                :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",                :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",                :limit => 200
      t.string   "etcstr2",                :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",                   :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",        :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",        :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",        :limit => 32
      t.datetime "updated_at"
    end
    
    add_index "d_cabinet_indices", ["d_cabinet_head_id"], :name => "idx_d_cabinet_indices_2"
    add_index "d_cabinet_indices", ["parent_cabinet_head_id"], :name => "idx_d_cabinet_indices_1"
    
  end
  
  def self.down
    drop_table :d_cabinet_indices
  end
end
