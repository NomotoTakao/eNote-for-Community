class DRssReader < ActiveRecord::Base
#  has_one :d_rss_trunk, :foreign_key => "id"

  #user_cdが購読中のd_rss_trunk_idを配列形式の文字列で返す。それぞれのデータの保存先DBが違うので一工夫する必要がある。
  def self.get_reader_turnk_ids(user_cd)
    ids = Array.new
    rets = find(:all, :conditions => ["delf = 0 AND user_cd = ?", user_cd])
    rets.each do |ret|
      #配列にidをセット
      ids << ret.d_rss_trunk_id
    end
    if ids.empty?
      return -1
    else
      return ids.join(",")
    end
  end

end
