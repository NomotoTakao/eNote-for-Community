class AddColumnToDBbsBoard < ActiveRecord::Migration
  def self.up
#    add_column :d_bbs_boards, :sort_no, :integer, :limit => 8, :default => 0
  end

  def self.down
#    remove_column :d_bbs_boards, :sort_no
  end
end
