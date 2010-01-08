class MMenu < ActiveRecord::Base

  #ヘッダ部メニュー用データを返す
  def self.get_menu_head_data(user_cd)

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    menus = Hash.new

    select_sql = " DISTINCT m_menus.*"

    # m_menusテーブルとm_menu_authsテーブルの結合句は共通で使える
    joins_sql = " INNER JOIN m_menu_auths ON m_menu_auths.menu_id = m_menus.id"
    # ログインユーザーの所属組織は共通で使える

    org_list = MUserBelong.get_belong_org_list(user_cd)
    belongs_sql = "m_menu_auths.org_cd IN (#{MOrg.edit_org_consider_lvl(org_list)})"

    #常に表示される基本メニュー
    conditions_sql = "m_menus.delf = :delf"
    conditions_sql += " AND m_menu_auths.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_menus.public_flg = :public_flg"
    conditions_param[:public_flg] = 0
    conditions_sql += " AND m_menus.parent_menu_id = :parent_menu_id"
    conditions_param[:parent_menu_id] = 0
    conditions_sql += " AND m_menus.menu_kbn = :menu_kbn"
    conditions_param[:menu_kbn] = 0
    conditions_sql += " AND (#{belongs_sql} OR m_menu_auths.org_cd = '0' OR m_menu_auths.user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd
    order_sql = "sort_no ASC"

    recs = find(:all, :select=>select_sql, :joins=>joins_sql, :conditions =>[conditions_sql, conditions_param], :order=>order_sql)
    menus[:top] = recs

    conditions_sql = "m_menus.delf = :delf"
    conditions_sql += " AND m_menu_auths.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_menus.public_flg = :public_flg"
    conditions_param[:public_flg] = 0
    conditions_sql += " AND m_menus.parent_menu_id <> :parent_menu_id"
    conditions_param[:parent_menu_id] = 0
    conditions_sql += " AND m_menus.menu_kbn = :menu_kbn"
    conditions_param[:menu_kbn] = 0
    conditions_sql += " AND (#{belongs_sql} OR m_menu_auths.org_cd = '0' OR m_menu_auths.user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd
    order_sql = "m_menus.parent_menu_id, sort_no ASC"

    recs = find(:all, :select=>select_sql, :joins=>joins_sql, :conditions => [conditions_sql, conditions_param], :order => order_sql)

    menus[:child] = Array.new
    parent_id = 0
    menu_array = Array.new

    recs.each do |rec|
      if parent_id != rec.parent_menu_id
        if parent_id != 0
          #menusにTOPメニューの子供メニューの配列をセット
          menus[:child] << menu_array
        end
        #子供メニュー配列を初期化
        menu_array = Array.new
        parent_id = rec.parent_menu_id
      end
      menu_array << rec
    end
    #最後にもmenusにTOPメニューの子供メニューの配列をセット
    menus[:child] << menu_array

    return menus

  end

  #自分にぶら下がる子供メニューの件数をカウントする
  def self.get_child_cnt(id)
    self.count_by_sql(["SELECT COUNT(*) FROM m_menus WHERE parent_menu_id = ?", id])
  end

  #サイド部メニュー用データを返す
  def self.get_menu_side_data(user_cd)

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""
    belongs_sql = ""

    menus = Hash.new

    # メニューの違いはm_menusテーブルのmenu_kbnだけなので、SQLは一か所だけの記述にする。
    joins_sql = "INNER JOIN m_menu_auths ON m_menu_auths.menu_id = m_menus.id"
    belongs_list = MUserBelong.new.get_belong_org user_cd
    belongs_list.each do |org|
      unless belongs_sql.empty?
        belongs_sql += " OR "
      end
      belongs_sql += "m_menu_auths.org_cd = '#{org.org_cd}'"
    end

    conditions_sql = "m_menus.delf = :delf"
    conditions_sql += " AND m_menu_auths.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_menus.public_flg = :public_flg"
    conditions_param[:public_flg] = 0
    conditions_sql += " AND m_menus.menu_kbn = ':menu_kbn'"
    conditions_sql += " AND (#{belongs_sql} OR m_menu_auths.org_cd = '0' OR m_menu_auths.user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd
    order_sql = "sort_no ASC"

    #システムメニュー
    conditions_param[:menu_kbn] = 1
    recs = find(:all, :joins=>joins_sql, :conditions =>[conditions_sql, conditions_param], :order => order_sql)
    menus[:system] = recs

    #社内の他リンクメニュー
    conditions_param[:menu_kbn] = 2
    recs = find(:all, :joins=>joins_sql, :conditions => [conditions_sql, conditions_param], :order => order_sql)
    menus[:inside] = recs

    #社外の他リンクメニュー
    conditions_param[:menu_kbn] = 3
    recs = find(:all, :joins=>joins_sql, :conditions => [conditions_sql, conditions_param], :order => order_sql)
    menus[:outside] = recs

    return menus

  end

  #
  # 指定されたメニューIDの下に連なるメニュー一覧を取得する。
  #
  # @param parent_menu_id - 親メニューID
  #
  def self.get_item_by_parent_menu_id parent_menu_id

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql = "m_menus.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += "AND m_menus.parent_menu_id = :parent_menu_id "
    conditions_param[:parent_menu_id] = parent_menu_id

    order_sql = " m_menus.sort_no ASC"

    MMenu.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  def self.delete_menu menu_id

    m_menu = MMenu.find(:first, :conditions=>{:id=>menu_id})
    unless m_menu.nil?
      m_menu.delf = '1'
      m_menu.save
    end

  end

  def self.get_max_sort_no

    select_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    select_sql = "sort_no"
    conditions_sql = " m_menus.delf = :delf"
    conditions_param[:delf] = 0
    order_sql = " sort_no DESC"

    MMenu.find(:first, :select=>select_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql).sort_no
  end

  #
  # 表示順が重複している場合、」既存の表示順をずらす。
  #
  # @param sort_no  - 表示順
  # @param menu_kbn - メニュー区分(渡されたメニュー区分で重複が無いかを調べる)
  # @params parent_menu_id - 親メニューID
  # @params old_sort_no - 旧表示順
  #
  def self.move_sort_no sort_no, menu_kbn, parent_menu_id, old_sort_no

    sql = ""
    conditions_sql = ""
    conditions_param = Hash.new

    conditions_sql = " m_menus.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_menus.sort_no = :sort_no"
    conditions_param[:sort_no] = sort_no
    conditions_sql += " AND m_menus.menu_kbn = :menu_kbn"
    conditions_param[:menu_kbn] = menu_kbn
    conditions_sql += " AND m_menus.parent_menu_id = :parent_menu_id"
    unless parent_menu_id.nil? or parent_menu_id.empty?
      conditions_param[:parent_menu_id] = parent_menu_id
    else
      conditions_param[:parent_menu_id] = 0.to_s
      parent_menu_id = 0.to_s
    end

    # 選択された区分で同じ表示順の項目が存在するかをチェック
    m_menus = MMenu.find(:first, :conditions=>[conditions_sql, conditions_param])
    unless m_menus.nil?
      unless old_sort_no.nil? or old_sort_no.empty?
        if sort_no.to_i == old_sort_no.to_i
          sql = "UPDATE m_menus SET sort_no = sort_no + 1 WHERE sort_no >= :sort_no AND m_menus.menu_kbn = :menu_kbn AND m_menus.parent_menu_id = :parent_menu_id"
        elsif sort_no.to_i < old_sort_no.to_i
          sql = "UPDATE m_menus SET sort_no = sort_no + 1 WHERE sort_no >= :sort_no AND sort_no <= :old_sort_no AND m_menus.menu_kbn = :menu_kbn AND m_menus.parent_menu_id = :parent_menu_id"
        else
          sql = "UPDATE m_menus SET sort_no = sort_no - 1 WHERE sort_no <= :sort_no AND sort_no > :old_sort_no AND m_menus.menu_kbn = :menu_kbn AND m_menus.parent_menu_id = :parent_menu_id"
        end
      else
        sql = "UPDATE m_menus SET sort_no = sort_no + 1 WHERE sort_no >= :sort_no AND  m_menus.menu_kbn = :menu_kbn AND m_menus.parent_menu_id = :parent_menu_id"
      end
      connection.execute(sql.gsub(":sort_no", sort_no).gsub(":old_sort_no", old_sort_no).gsub(":menu_kbn", menu_kbn).gsub(":parent_menu_id", parent_menu_id))
    end
  end

  #
  # 指定されたメニュー区分、メニューIDの下に連なるメニュー一覧を取得する。
  #
  # @param menu_kbn - メニュー区分
  # @param parent_menu_id - 親メニューID
  #
  def self.get_item_by_parent_menuid_menukbn menu_kbn, parent_menu_id

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql = "m_menus.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND m_menus.menu_kbn = :menu_kbn "
    conditions_param[:menu_kbn] = menu_kbn
    conditions_sql += " AND m_menus.parent_menu_id = :parent_menu_id "
    conditions_param[:parent_menu_id] = parent_menu_id

    order_sql = " m_menus.sort_no ASC"

    MMenu.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end
end
