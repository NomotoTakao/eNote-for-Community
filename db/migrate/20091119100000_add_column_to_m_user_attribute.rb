class AddColumnToMUserAttribute < ActiveRecord::Migration
  def self.up
#    add_column :m_user_attributes, :director_flg, :char, :default=>0
#    add_column :m_user_attributes, :sort_no, :integer
    add_column :m_user_attributes, :position_cd_org, :integer, :limit => 8
  end

  def self.down
    remove_column :m_user_attributes, :position_cd_org
#    remove_column :m_user_attributes, :sort_no
#    remove_column :m_user_attributes, :director_flg
  end
end
