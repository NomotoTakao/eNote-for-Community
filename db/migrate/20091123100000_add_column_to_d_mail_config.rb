class AddColumnToDMailConfig < ActiveRecord::Migration
  def self.up
#    add_column :d_mail_configs, :limit_days, :integer, :limit => 8, :default => 7
  end

  def self.down
#    remove_column :d_mail_configs, :limit_days
  end
end
