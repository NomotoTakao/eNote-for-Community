class DBbsThread < ActiveRecord::Base
  belongs_to :d_bbs_board
  has_many :d_bbs_comments
end
