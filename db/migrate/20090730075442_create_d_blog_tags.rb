class CreateDBlogTags < ActiveRecord::Migration
  def self.up
    create_table :d_blog_tags do |t|
      t.integer  :d_blog_body_id,                 :default=>0,  :null=>false
      t.string   :category
      t.integer  :count,                          :default=>0
      t.integer  :etcint1,                        :default=>0
      t.integer  :etcint2,                        :default=>0
      t.integer  :etcdec1,                        :default=>0
      t.integer  :etcdec2,                        :default=>0
      t.string   :etcstr1,           :limit=>200
      t.string   :etcstr2,           :limit=>200
      t.text     :etctxt1
      t.text     :etctxt2
      t.integer  :delf,              :limit=>2,   :default=>0
      t.string   :deleted_user_cd,   :limit=>32
      t.datetime :deleted_at
      t.string   :created_user_cd,   :limit=>32
      t.datetime :created_at
      t.string   :updated_user_cd,   :limit=>32
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :d_blog_tags
  end
end
