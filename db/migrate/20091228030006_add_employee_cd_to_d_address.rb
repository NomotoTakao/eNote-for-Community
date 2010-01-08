class AddEmployeeCdToDAddress < ActiveRecord::Migration
  def self.up
    add_column :d_addresses, :employee_cd, :string, :limit=>8
  end

  def self.down
    remove_column :d_addresses, :employee_cd
  end
end
