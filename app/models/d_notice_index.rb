class DNoticeIndex < ActiveRecord::Base

  belongs_to :d_notice_head

  def get_list user_cd, org_cd

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

#    joins_sql = " INNER JOIN d_notice_auths ON d_notice_indices.notice_head_id = d_notice_auths.d_notice_head_id "

    conditions_sql = " d_notice_indices.delf = :delf "
#    conditions_sql += " AND d_notice_auths.delf = :delf "
    conditions_param[:delf] = "0"
#    conditions_sql += " AND (d_notice_auths.user_cd = :user_cd "
#    conditions_param[:user_cd] = user_cd
#    conditions_sql +=      " OR d_notice_auths.org_cd = :org_cd) "
#    conditions_param[:org_cd] = org_cd
#    conditions_sql += " AND d_notice_auths.auth_kbn = :kbn "
#    conditions_param[:kbn] = 2

    order_sql = " d_notice_indices.id ASC"

    DNoticeIndex.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #ヘッダ部メニュー用データを返す
  def self.get_menu_head_data(user_cd)

    menus = Hash.new

    #お知らせの1階層目（TOP）メニュー
    recs = get_index_list 0, user_cd, 1
    menus[:top] = recs
#    menus[:child] = Array.new
#    menus[:top].each do |rec|
#      menus[:child] << get_index_list(rec.id, user_cd)
#    end

    #お知らせの2階層目以降のメニュー
    recs = find(:all, :conditions => ["parent_notice_head_id <> 0 AND delf = 0"], :order => "parent_notice_head_id,sort_no")

    menus[:child] = Array.new
    parent_id = 0
    menu_array = Array.new

    recs.each do |rec|
      if parent_id != rec.parent_notice_head_id
        if parent_id != 0
          #menusに2階層目以降のメニューの配列をセット
          menus[:child] << menu_array
        end
        #子供メニュー配列を初期化
        menu_array = Array.new
        parent_id = rec.parent_notice_head_id
      end
      menu_array << rec
#      menu_array << get_index_list(0, user_cd)
    end
    #最後にもmenusにTOPメニューの子供メニューの配列をセット
    menus[:child] << menu_array

    return menus

  end

  #自分にぶら下がる子供メニューの件数をカウントする
  def self.get_child_cnt(id)
    self.count_by_sql(["SELECT COUNT(*) FROM d_notice_indices WHERE parent_notice_head_id = ?", id])
  end


  def self.move_sort_no sort_no, old_sort_no, parent_notice_head_id

    sql = ""

#    sort_no = sort_no.to_i
#    old_sort_no = old_sort_no.to_i

    if sort_no != old_sort_no
      if sort_no.to_i < old_sort_no.to_i
        sql = "UPDATE d_notice_indices SET sort_no = sort_no + 1 WHERE delf=0 AND parent_notice_head_id = :parent_notice_head_id AND sort_no >= :sort_no AND sort_no < :old_sort_no"
      else
        sql = "UPDATE d_notice_indices SET sort_no = sort_no - 1 WHERE delf=0 AND parent_notice_head_id = :parent_notice_head_id AND sort_no <= :sort_no AND sort_no > :old_sort_no"
      end
      connection.execute(sql.gsub(":sort_no", sort_no).gsub(":old_sort_no", old_sort_no).gsub(":parent_notice_head_id", parent_notice_head_id))
    end
  end

  #
  # お知らせINDEXに表示するお知らせ一覧を取得します。
  # d_notice_authsテーブルを参照して権限があるもののみ取得します。
  #
  # @param parent_notice_head_id - 上位のお知らせ項目ID
  # @param user_cd - ログインユーザーのユーザーCD(権限の判断に利用)
  #
  def self.get_index_list parent_notice_head_id, user_cd, auth_kbn

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql = "INNER JOIN d_notice_heads ON d_notice_indices.d_notice_head_id = d_notice_heads.id"
    joins_sql += " INNER JOIN d_notice_auths ON d_notice_auths.d_notice_head_id = d_notice_heads.id"
    #TODO 権限テーブルも結合する
    conditions_sql = " d_notice_indices.delf = :delf"
    conditions_sql += " AND d_notice_heads.delf = :delf"
    conditions_sql += " AND d_notice_auths.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_notice_indices.parent_notice_head_id = :parent_notice_head_id"
    belong_orgs = MUserBelong.find(:all, :conditions=>{:delf=>0, :user_cd=>user_cd})
    belong_sql = ""
    tmp_sql = ""
    unless belong_orgs.length == 0
      belong_orgs.each do |org|
        unless tmp_sql.empty?
          tmp_sql += " OR "
        end
        tmp_sql += "d_notice_auths.org_cd = SUBSTR(':org_cd', 0, LENGTH(d_notice_auths.org_cd)+1)".gsub(":org_cd", org.org_cd)
      end
      unless tmp_sql.empty?
        belong_sql = " AND (#{tmp_sql})"
      end
    end
    conditions_sql += " AND ((d_notice_auths.org_cd != '' #{belong_sql}) OR d_notice_auths.org_cd = '0' OR d_notice_auths.user_cd = :user_cd)"

#   unless auth_kbn != 0
        conditions_sql += " AND d_notice_auths.auth_kbn = :auth_kbn "
        conditions_param[:auth_kbn] = auth_kbn
#    end
    conditions_param[:user_cd] = user_cd
    conditions_param[:parent_notice_head_id] = parent_notice_head_id
    order_sql = "sort_no ASC"

    DNoticeIndex.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # お知らせ新規作成画面の「お知らせボードの選択」リストボックスの内容を取得する。
  #
  # @param user_cd - ログインユーザーCD
  #
  def self.get_select_board_list user_cd

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql = "INNER JOIN d_notice_heads ON d_notice_indices.d_notice_head_id = d_notice_heads.id"
    joins_sql += " INNER JOIN d_notice_auths ON d_notice_auths.d_notice_head_id = d_notice_heads.id"
    #TODO 権限テーブルも結合する
    conditions_sql = " d_notice_indices.delf = :delf"
    conditions_sql += " AND d_notice_heads.delf = :delf"
    conditions_sql += " AND d_notice_auths.delf = :delf"
    conditions_param[:delf] = 0
#    conditions_sql += " AND d_notice_indices.parent_notice_head_id = :parent_notice_head_id"
    belong_orgs = MUserBelong.find(:all, :conditions=>{:delf=>0, :user_cd=>user_cd})
    belong_sql = ""
    tmp_sql = ""
    unless belong_orgs.length == 0
      belong_orgs.each do |org|
        unless tmp_sql.empty?
          tmp_sql += " OR "
        end
        tmp_sql += "d_notice_auths.org_cd = SUBSTR(':org_cd', 0, LENGTH(d_notice_auths.org_cd)+1)".gsub(":org_cd", org.org_cd)
      end
      unless tmp_sql.empty?
        belong_sql = " AND (#{tmp_sql})"
      end
    end
    conditions_sql += " AND ((d_notice_auths.org_cd != '' #{belong_sql}) OR d_notice_auths.org_cd = '0' OR d_notice_auths.user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd
#    conditions_param[:parent_notice_head_id] = parent_notice_head_id
    conditions_sql += " AND d_notice_indices.index_type = 'b'"
    conditions_sql += " AND d_notice_auths.auth_kbn = 2"
    order_sql = "sort_no ASC"

    DNoticeIndex.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  #指定された親IDをもつお知らせデータを返す
  #
  def self.get_notice_board_list parent_notice_head_id

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql += " d_notice_indices.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_notice_indices.parent_notice_head_id = :parent_notice_head_id "
    unless parent_notice_head_id.nil? or parent_notice_head_id.to_s.empty?
      conditions_param[:parent_notice_head_id] = parent_notice_head_id
    else
      conditions_param[:parent_notice_head_id] = 0
    end

    order_sql = " sort_no ASC"

    return find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 指定されたお知らせインデックスレコードを取得します。
  #
  # @param head_id - ヘッダID
  # @return お知らせインデックスレコード
  #
  def self.get_noticeindex_by_head_id head_id

    conditions_sql = ""
    conditions_param = {}
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_notice_head_id = :d_notice_head_id "
    conditions_param[:d_notice_head_id] = head_id

    DNoticeIndex.find(:first, :conditions=>[conditions_sql, conditions_param]);
  end
end
