class DBulletinBody < ActiveRecord::Base
  belongs_to :d_bulletin_head

  #引数の社員CD宛の回覧板データを取得する
  def self.get_mybulletin(user_cd, answer_kbn, sword)
    sql = <<-SQL
      SELECT
        b.user_cd,
        b.answer_kbn,
        b.answer_date,
        b.comment,
        b.id,
        b.d_bulletin_head_id,
        h.title,
        h.post_user_cd,
        h.post_user_name,
        h.bulletin_date_from,
        h.bulletin_date_to,
        h.body,
        h.answer_public_kbn
      FROM d_bulletin_heads h, d_bulletin_bodies b
      WHERE
          h.id = b.d_bulletin_head_id
      AND h.delf = 0
      AND b.delf = 0
      AND (h.bulletin_date_from <= '#{Date.today}' OR h.post_user_cd = '#{user_cd}')
      AND b.user_cd = '#{user_cd}'
    SQL

    case answer_kbn.to_i
      when 0,1    #未読、既読
        sql += " AND b.answer_kbn = #{answer_kbn}"
        sql += " AND (h.bulletin_date_to >= '#{Date.today}' OR h.post_user_cd = '#{user_cd}')"
      when 2      #期限切れ
        sql += " AND (h.bulletin_date_to <= CAST('#{Date.today}' AS DATE) AND h.post_user_cd = '#{user_cd}')"
      when 3      #自分が作成したもの
        sql += " AND h.post_user_cd = '#{user_cd}' "
      when 9      #あいまい検索
        sql += " AND (h.title like '%#{sword}%' OR h.post_user_name like '%#{sword}%' OR h.body like '%#{sword}%') "
    end
    sql += " ORDER BY h.bulletin_date_to "

    find_by_sql(sql)
  end

end
