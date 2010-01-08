class MProjectUser < ActiveRecord::Base

  #
  # 引数のプロジェクトコードに含まれる、ユーザリストを返す
  #
  def self.get_project_user_list(project_id)

    sql = <<-SQL
      SELECT
        t1.*,
        t3.name as user_name
      FROM
        m_project_users t1,
        m_projects t2,
        m_users t3
      WHERE
        t1.project_id = t2.id
      AND
        t1.user_cd = t3.user_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t3.delf = 0
      AND
        t2.id = #{project_id}
      ORDER BY
        t1.id
    SQL

    recs = find_by_sql(sql)
    return recs
  end

end
