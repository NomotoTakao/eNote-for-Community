class DRssReader < ActiveRecord::Base
  has_one :d_rss_trunk, :foreign_key => "id"

end
