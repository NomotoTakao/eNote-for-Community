class DAddressGroup < ActiveRecord::Base

  validates_presence_of :title => "を入力してください。"

  class << self

    HUMANIZED_ATTRIBUTE_KEY_NAMES = {
     "title"          => "タイトル"
    }

    def human_attribute_name(attribute_key_name)
      HUMANIZED_ATTRIBUTE_KEY_NAMES[attribute_key_name] || super
    end

  end

  #
  # 引数のユーザコードに該当するグループデータを返す
  # (user_cd = '0'は共用グループのデータ)
  #
  def self.get_all_user_group(user_cd)

    sql = <<-SQL
      SELECT t1.*
      FROM d_address_groups t1
      WHERE
          t1.delf = 0
      AND t1.private_user_cd = '#{user_cd}'
      ORDER BY
        t1.id
    SQL
    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数のグループ名に該当するデータを返す
  # 但し引数のid指定の場合は、id以外のデータで検索する
  #
  def self.duplicate_check_data(id, title, user_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM d_address_groups t1
      WHERE
        t1.delf = 0
      AND
        t1.title = '#{title}'
      AND
        t1.private_user_cd = '#{user_cd}'
    SQL

    if id != 0
      sql += <<-SQL
        AND
          t1.id != #{id}
      SQL
    end

    sql += <<-SQL
      LIMIT 1
    SQL

    recs = find_by_sql(sql)
    return recs
  end

end
