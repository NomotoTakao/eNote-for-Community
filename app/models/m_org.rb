class MOrg < ActiveRecord::Base
  has_many :d_cabinet_body

  #
  # 組織を新規に登録する処理
  #
  def self.create_org params, user_cd
    m_org = MOrg.new

    unless params[:org_cd].nil?
      m_org.org_cd = params[:org_cd]
      if m_org.org_cd.length == 2
        m_org.org_cd1 = m_org.org_cd
        m_org.org_cd2 = ""
        m_org.org_cd3 = ""
        m_org.org_cd4 = ""
      elsif m_org.org_cd.length == 4
        m_org.org_cd1 = m_org.org_cd[0..1]
        m_org.org_cd2 = m_org.org_cd[2..3]
        m_org.org_cd3 = ""
        m_org.org_cd4 = ""
      elsif m_org.org_cd.length == 6
        m_org.org_cd1 = m_org.org_cd[0..1]
        m_org.org_cd2 = m_org.org_cd[2..3]
        m_org.org_cd3 = m_org.org_cd[4..5]
        m_org.org_cd4 = ""
      elsif m_org.org_cd.length == 8
        m_org.org_cd1 = m_org.org_cd[0..1]
        m_org.org_cd2 = m_org.org_cd[2..3]
        m_org.org_cd3 = m_org.org_cd[4..5]
        m_org.org_cd4 = m_org.org_cd[6..7]
      end
    end
    unless params[:org_cd1].nil?
      m_org.org_cd1 = params[:org_cd1]
    end
    unless params[:org_cd2].nil?
      org_cd2 = params[:org_cd2][params[:org_cd1].length..params[:org_cd2].length]
      m_org.org_cd2 = org_cd2
    end
    unless params[:org_cd3].nil?
      org_cd3 = params[:org_cd3][params[:org_cd2].length..params[:org_cd3].length]
      m_org.org_cd3 = org_cd3
    end
    unless params[:org_lvl].nil?
      m_org.org_lvl = params[:org_lvl]
    end
    unless params[:org_name1].nil?
      m_org.org_name1 = params[:org_name1]
    end
    unless params[:org_name2].nil?
      m_org.org_name2 = params[:org_name2]
    end
    unless params[:org_name3].nil?
      m_org.org_name3 = params[:org_name3]
    end
    unless params[:org_name4].nil?
      m_org.org_name4 = params[:org_name4]
    end
    unless params[:org_name].nil?
      if m_org.org_lvl == 1
        m_org.org_name1 = params[:org_name]
      elsif m_org.org_lvl == 2
        m_org.org_name2 = params[:org_name]
      elsif m_org.org_lvl == 3
        m_org.org_name3 = params[:org_name]
      elsif m_org.org_lvl == 4
        m_org.org_name4 = params[:org_name]
      end
    end
    unless params[:tel].nil?
      m_org.tel = params[:tel]
    end
    unless params[:fax].nil?
      m_org.fax = params[:fax]
    end
    unless params[:sort_no].nil?
      m_org.sort_no = params[:sort_no]
    end

    m_org.created_user_cd = user_cd
    m_org.created_at = Time.now
    m_org.updated_user_cd = user_cd
    m_org.updated_at = Time.now

    begin
      m_org.save!
    rescue
      p $!
      raise
    end
  end

  #
  # 既存組織の登録情報を更新する処理
  #
  def self.update_org params, user_cd

    m_org = MOrg.find(:first, :conditions=>{:delf=>0, :id=>params[:id]})
    unless m_org.nil?
      unless params[:org_lvl].nil?
        m_org.org_lvl = params[:org_lvl]
      end
      unless params[:org_name1].nil?
        m_org.org_name1 = params[:org_name1]
      end
      unless params[:org_name2].nil?
        m_org.org_name2 = params[:org_name2]
      end
      unless params[:org_name3].nil?
        m_org.org_name3 = params[:org_name3]
      end
      unless params[:org_name4].nil?
        m_org.org_name4 = params[:org_name4]
      end
      unless params[:org_name].nil?
        if m_org.org_lvl == 1
          m_org.org_name1 = params[:org_name]
        elsif m_org.org_lvl == 2
          m_org.org_name2 = params[:org_name]
        elsif m_org.org_lvl == 3
          m_org.org_name3 = params[:org_name]
        elsif m_org.org_lvl == 4
          m_org.org_name4 = params[:org_name]
        end
      end
      unless params[:tel].nil?
        m_org.tel = params[:tel]
      end
      unless params[:fax].nil?
        m_org.fax = params[:fax]
      end
      unless params[:sort_no].nil?
        m_org.sort_no = params[:sort_no]
      end

      m_org.updated_user_cd = user_cd
      m_org.updated_at = Time.now

      begin
        m_org.save!
      rescue
        p $!
        raise
      end
    end
  end

  #
  # 既存組織を論理削除する処理
  #
  def self.delete_org params, user_cd

    m_org = MOrg.find(:first, :conditions=>{:delf=>0, :id=>params[:id]})
    unless m_org.nil?
      m_org.delf = 1

      m_org.deleted_user_cd = user_cd
      m_org.deleted_at = Time.now

      begin
        m_org.save!
      rescue
        p$!
        raise
      end
    end
  end

  #
  # 登録されているすべての組織情報を取得する。
  #
  def get_orgs

    conditions_sql = ""
    conditions_param = {}

    order_sql = ""

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"

    order_sql = " org_cd ASC"

    MOrg.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 組織コードをキーとした、組織名称のハッシュテーブルを取得する。
  #
  def get_hash_cd_and_name

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""
    result = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0

    order_sql = " id ASC"

    orgs = MOrg.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)

    orgs.each do |org|
      org_name = ""
      if org.org_name4 != ""
        org_name = org.org_name4
      elsif org.org_name3 != ""
        org_name = org.org_name3
      elsif org.org_name2 != ""
        org_name = org.org_name2
      elsif org.org_name1 != ""
        org_name = org.org_name1
      end
      result[org.org_cd] = org_name
    end

    result
  end

  #
  # 社内ブログの投稿者一覧の組織ツリーを取得する。
  #
  # @param org_lvl - ツリーの階層
  # @param org_cd - ツリーで選択された組織の組織コード
  # @return 指定された組織の下階層に組織が存在する場合は、その配列
  #
  def get_blogger_org_list org_lvl, org_cd

    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    order_sql = ""
    org_cd1 = ""
    org_cd2 = ""
    org_cd3 = ""
    org_cd4 = ""

    unless org_cd.empty?
      if org_lvl == 1
        org_cd1 = org_cd[0..1]
        org_lvl = 2
      elsif org_lvl == 2
        org_cd1 = org_cd[0..1]
        org_cd2 = org_cd[2..3]
        org_lvl = 3
      elsif org_lvl == 3
        org_cd1 = org_cd[0..1]
        org_cd2 = org_cd[2..3]
        org_cd3 = org_cd[4..5]
        org_lvl = 4
      elsif org_lvl == 4
# 現時点では4階層までしか存在しないので、4階層目がされた場合には配下の組織がないことを示すためにnilを返す。
#        org_cd1 = org_cd[0..1]
#        org_cd2 = org_cd[2..3]
#        org_cd3 = org_cd[4..5]
#        org_cd4 = org_cd[6..8]
        return nil
      end
    end

    select_sql = " org_cd, org_name#{org_lvl} as org_name, org_lvl"
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND org_lvl = :org_lvl "
    conditions_param[:org_lvl] = org_lvl
    unless org_cd1.empty?
      conditions_sql += " AND org_cd1 = :org_cd1"
      conditions_param[:org_cd1] = org_cd1
    end
    unless org_cd2.empty?
      conditions_sql += " AND org_cd2 = :org_cd2"
      conditions_param[:org_cd2] = org_cd2
    end
    unless org_cd3.empty?
      conditions_sql += " AND org_cd3 = :org_cd3"
      conditions_param[:org_cd3] = org_cd3
    end
# 現時点では4階層までしか存在しないので、4階層目がされた場合には配下の組織がないことを示すためにnilを返す。
#    unless org_cd4.empty?
#      conditions_sql += " AND org_cd4 = :org_cd4"
#      conditions_param[:org_cd4] = org_cd4
#    end

    order_sql = " org_cd ASC"

    MOrg.find(:all, :select=>select_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 渡された組織の情報を取得する。
  #
  # @param org_cd - 組織CD
  #
  def get_org_info org_cd

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND org_cd = :org_cd"
    conditions_param[:org_cd] = org_cd.to_s

    MOrg.find(:first, :conditions=>[conditions_sql, conditions_param])
  end

  #
  #引数の組織コードを持つ社員を取得する。
  #
  def self.get_org_user(org_cd)
    sql = <<-SQL
      SELECT
        b.user_cd,
        b.org_cd,
        a.name
      FROM m_users a, m_user_belongs b, m_user_attributes c
      WHERE
          a.user_cd = b.user_cd
      AND a.user_cd = c.user_cd
      AND a.delf = 0
      AND b.delf = 0
      AND c.delf = 0
      AND b.org_cd = '#{org_cd}'
      ORDER BY
        c.sort_no, c.position_cd, c.joined_date
    SQL
    find_by_sql(sql)
  end

  #
  # 公開対象組織ツリーに表示する組織を取得する。
  #
  def get_public_orgs

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND org_lvl != :org_lvl"
    conditions_param[:org_lvl] = 4

    order_sql = "org_cd"

    MOrg.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 登録されているすべての組織情報を取得する。
  # 組織名称を考慮(該当データの最階位の組織名称を返却)
  #
  def self.get_orgs_consider_name

    sql = <<-SQL
      SELECT
        t1.*,
        case
          when trim(t1.org_name4) != '' then t1.org_name4
          when trim(t1.org_name3) != '' then t1.org_name3
          when trim(t1.org_name2) != '' then t1.org_name2
          when trim(t1.org_name1) != '' then t1.org_name1
        end as org_name
      FROM
        m_orgs t1
      WHERE
        t1.delf = 0
      ORDER BY
        t1.sort_no
    SQL

    recs = find_by_sql(sql)
    return recs

  end


  def self.get_org_name org_cd
    result = ""

    m_org = MOrg.find(:first, :conditions=>{:delf=>0, :org_cd=>org_cd})

    unless m_org.nil?
      unless m_org.org_name4.nil? or m_org.org_name4.empty?
        result = m_org.org_name4
      else
        unless m_org.org_name3.nil? or m_org.org_name3.empty?
          result = m_org.org_name3
        else
          unless m_org.org_name2.nil? or m_org.org_name2.empty?
            result = m_org.org_name2
          else
            unless m_org.org_name1.nil?
              result = m_org.org_name1
            end
          end
        end
      end
    end

    return result
  end


  #
  # 指定された組織レベルの下位組織一覧を取得する。
  #
  # @param org_lvl - 現在の組織レベル
  # @param org_cd - 選択された組織の組織CD
  #
  def self.get_org_list org_lvl, org_cd

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql += " m_orgs.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_orgs.org_lvl = :org_lvl"
    conditions_param[:org_lvl] = org_lvl
    unless org_cd.nil? or org_cd.empty?
      conditions_sql += " AND SUBSTR(m_orgs.org_cd, 0, LENGTH(:org_cd) + 1) = :org_cd"
      conditions_param[:org_cd] = org_cd
    end
    order_sql += " m_orgs.org_cd ASC"

    MOrg.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 指定された組織レベルの下位組織一覧を取得する。
  #
  # @param org_lvl - 現在の組織レベル
  # @param org_cd - 選択された組織の組織CD
  # @param hyphen_mode - 0:ハイフン以外のデータ, 1:ハイフンのデータ
  #
  def self.get_org_list_consider_hyphen org_lvl, org_cd, hyphen_mode

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql += " m_orgs.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_orgs.org_lvl = :org_lvl"
    conditions_param[:org_lvl] = org_lvl
    unless org_cd.nil? or org_cd.empty?
      conditions_sql += " AND SUBSTR(m_orgs.org_cd, 0, LENGTH(:org_cd) + 1) = :org_cd"
      conditions_param[:org_cd] = org_cd
    end
    if hyphen_mode == 0
      if org_lvl == 2
        conditions_sql += " AND m_orgs.org_name2 != '-'"
      elsif org_lvl == 3
        conditions_sql += " AND m_orgs.org_name3 != '-'"
      end
    else
      if org_lvl == 3
        conditions_sql += " AND m_orgs.org_name2 = '-'"
      elsif org_lvl == 4
        conditions_sql += " AND m_orgs.org_name3 = '-'"
      end
    end
    order_sql += " m_orgs.org_cd ASC"

    MOrg.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  def self.get_under_most_layer_org_name org

    result = ""

    unless org.org_name4 == "-"
      result = org.org_name4
    else
      unless org.org_name3 == "-"
        result = org.org_name3
      else
        unless org.org_name2 == "-"
          result = org.org_name2
        else
          result = org.org_name1
        end
      end
    end

    return result
  end

  #
  #部署リストを上階層の部署を複数検索を考慮した形に編集する
  #ex)所属部署が'1010','2030' -> '10', '1010', '20', '2030'
  #
  def self.edit_org_consider_lvl(org_list)
    org_sql = ""
    for i in 0..(org_list.size - 1)
      if i > 0
        org_sql += ", "
      end
      #組織レベルに応じてin句を作成
      org = org_list[i]
      if org.org_lvl.to_i >= 1
        org_sql += "'"
        org_sql += org.org_cd1
        org_sql += "'"
      end
      if org.org_lvl.to_i >= 2
        org_sql += ", "
        org_sql += "'"
        org_sql += (org.org_cd1 + org.org_cd2)
        org_sql += "'"
      end
      if org.org_lvl.to_i >= 3
        org_sql += ", "
        org_sql += "'"
        org_sql += (org.org_cd1 + org.org_cd2 + org.org_cd3)
        org_sql += "'"
      end
      if org.org_lvl.to_i >= 4
        org_sql += ", "
        org_sql += "'"
        org_sql += (org.org_cd1 + org.org_cd2 + org.org_cd3 + org.org_cd4)
        org_sql += "'"
      end
    end
    return org_sql
  end


end
