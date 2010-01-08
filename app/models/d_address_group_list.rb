class DAddressGroupList < ActiveRecord::Base
  belongs_to :d_address, :conditions=>{:delf=>0}
  #
  # 引数のアドレスグループIDに該当するユーザデータを返す
  # @param id - アドレス帳グループID
  #
  def self.get_data_by_group_id(id)

    sql = <<-SQL
      SELECT t1.*,
             t2.title,
             t3.user_cd, t3.name
      FROM d_address_group_lists t1,
           d_address_groups t2,
           d_addresses t3
      WHERE
          t1.delf = 0
      AND
          t2.delf = 0
      AND
          t3.delf = 0
      AND
          t1.d_address_group_id = t2.id
      AND
          t1.d_address_id = t3.id
      AND
          t2.id = #{id}
      ORDER BY
        t1.id
    SQL
    recs = find_by_sql(sql)
    return recs
  end

  #
  # 指定するユーザーの共有グループ一覧を集臆する。
  #
  # @param keyword - 検索語(中間一致検索)
  # @param user_cd - ユーザーCD
  #
  def self.group_list keyword, user_cd
    
    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    
    select_sql += " d_address_groups.id"
    select_sql += ",d_address_groups.title "
    joins_sql += " INNER JOIN d_address_groups on d_address_groups.id = d_address_group_lists.id"
    conditions_sql += " d_address_groups.delf = :delf "
    conditions_sql += " AND d_address_group_lists.delf = :delf"
    conditions_param[:delf] = 0
    unless keyword.nil? or keyword.empty?
      conditions_sql += " AND d_address_groups.title like :keyword"
      conditions_param[:keyword] = "%" + keyword + "%"
    end
    conditions_sql += " AND d_address_groups.private_user_cd = :user_cd"
    conditions_param[:user_cd] = user_cd

    return find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param])
  end
end
