class DBulletinHead < ActiveRecord::Base
  has_many :d_bulletin_bodies, :conditions=>"delf=0"
  has_many :d_bulletin_file, :conditions=>"delf=0"


end
