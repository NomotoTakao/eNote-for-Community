class MKbn < ActiveRecord::Base

  #
  # お知らせ新規投稿画面に表示するTOP表示区分を取得します。
  # ログインユーザーの所属組織により、取得できる区分が異なる。
  #
  # @param user_cd - ログインユーザーCD
  # @return TOP表示区分
  #
  def self.get_notice_bodies_top_disp_kbn user_cd

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    # ログインユーザーの所属する組織一覧を求める。
    org_array = MUserBelong.new.get_belong_org user_cd
    tmp_conditions_sql = ""
    unless org_array.nil?
      org_array.each do |org|
        unless tmp_conditions_sql.empty?
          tmp_conditions_sql += " OR "
        end
        tmp_conditions_sql += " value_chr = SUBSTR('#{org.org_cd}%', 1, LENGTH(value_chr)) "
      end
    end

    select_sql += " DISTINCT m_kbns.*"
    conditions_sql += " m_kbns.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND kbn_cd = :kbn_cd"
    conditions_param[:kbn_cd] = 'd_notice_bodies_top_disp_kbn'
    conditions_sql += " AND kbn_id <> -1"
#    unless user_cd == "9999999"
      unless tmp_conditions_sql.empty?
        conditions_sql += " AND (#{tmp_conditions_sql})"
      end
#    end
    order_sql += " sort_no ASC"

    MKbn.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # お知らせ新規投稿画面に表示するホットトピック区分を取得する。
  #
  # @return ホットトピック区分
  #
  def self.get_hot_topic_kbn

    conditions_sql = ""
    conditions_param = {}

    conditions_sql += " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND kbn_cd = :kbn_cd"
    conditions_param[:kbn_cd] = 'd_notice_bodies_hottopic_flg'
    conditions_sql += " AND kbn_id != :kbn_id"
    conditions_param[:kbn_id] = -1

    MKbn.find(:all, :order=>:kbn_id, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # スケジュールに表示する種別の名称を取得します
  #
  # @return ハッシュ[区分id, 種別名称]
  #
  def self.get_plan_name_list()

    #区分M(種別)
    plan_list_work = MKbn.find(:all, :order=>:kbn_id, :conditions => ["kbn_cd = ? and delf = ?", "d_schedules_plan_kbn", 0])
    #ハッシュ[区分id, 種別名称]を作成
    plan_name_list = Hash.new{|hash,key| hash[key]=[]}
    plan_list_work.each { |plan|
      plan_name_list[plan.kbn_id] << plan.name
    }
    return plan_name_list

  end

  #
  # スケジュールに表示する種別の色を取得します
  #
  # @return ハッシュ[区分id, 色]
  #
  def self.get_plan_color_list()

    #区分M(種別)
    plan_list_work = MKbn.find(:all, :order=>:kbn_id, :conditions => ["kbn_cd = ? and delf = ?", "d_schedules_plan_kbn", 0])
    #配列[区分id, 色]を作成
    plan_color_list = Hash.new{|hash,key| hash[key]=[]}
    plan_list_work.each { |plan|
      plan_color_list[plan.kbn_id] << plan.value_chr
    }
    return plan_color_list

  end

  #
  # スケジュールに表示する種別の終日フラグを取得します
  #
  # @return ハッシュ[区分id, 終日フラグ(0:終日指定なし, 1:終日指定あり)]
  #
  def self.get_plan_allday_list()

    #区分M(種別)
    plan_list_work = MKbn.find(:all, :order=>:kbn_id, :conditions => ["kbn_cd = ? and delf = ?", "d_schedules_plan_kbn", 0])
    #配列[区分id, 色]を作成
    plan_allday_list = Hash.new{|hash,key| hash[key]=[]}
    plan_list_work.each { |plan|
      plan_allday_list[plan.kbn_id] << plan.value_int
    }
    return plan_allday_list

  end
end
