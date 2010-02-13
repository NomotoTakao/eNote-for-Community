class Cabinet::MineController < ApplicationController
  layout "portal", :except=>[:cabinet_list, :dialog, :create, :delete]

  def index
    #パンくずリストに表示させる
    @pankuzu += "Webメモリー"
  end

  #
  # キャビネットの一覧を取得します。
  #
  def cabinet_list

    @m_cabinet_setting = MCabinetSetting.find(:first, :conditions=>{:delf=>0})

    conditons_sql = ""
    conditions_param = {}
    joins_sql = ""

    order = params[:order]
    mode = params[:mode]

    if order.nil?
      order = "post_date"
    end

    if mode.nil? or mode == "1"
      order_sql = order + " DESC"
      next_mode = "2"
    else
      order_sql = order + " ASC"
      next_mode = "1"
    end

    if order == "title"
      @next_mode_title = next_mode
    elsif order == "file_name"
      @next_mode_file_name = next_mode
    elsif order == "post_date"
      @next_mode_post_date = next_mode
    elsif order == "expiration"
      # 残り日数は投稿日に読み替える。
      order_sql.gsub!("expiration", "post_date")
      if next_mode == "1"
        order_sql.gsub!("ASC", "DESC")
      elsif next_mode == "2"
        order_sql.gsub!("DESC", "ASC")
      end
      @next_mode_expiration = next_mode
    elsif order == "file_size"
      @next_mode_file_size = next_mode
    end

    @head = DCabinetHead.get_cabinethead_by_user_cd current_m_user.user_cd
    if @head.nil?
      # ヘッダレコードを作る
      DCabinetHead.new.create_private_cabinet current_m_user.user_cd
      @head = DCabinetHead.get_cabinethead_by_user_cd current_m_user.user_cd
    end

    joins_sql = " INNER JOIN d_cabinet_files ON d_cabinet_files.d_cabinet_body_id = d_cabinet_bodies.id"
    conditions_sql = " d_cabinet_bodies.delf = :delf "
    conditions_sql += " AND d_cabinet_files.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_cabinet_bodies.d_cabinet_head_id = :d_cabinet_head_id "
    conditions_sql += " AND d_cabinet_files.d_cabinet_head_id = :d_cabinet_head_id "
    conditions_param[:d_cabinet_head_id] = @head.id
#    @cabinet_list = DCabinetBody.find(:all, :order=>" post_date DESC ", :conditions=>[conditions_sql, conditions_param])
    # 有効期限内のものだけに絞る
    conditions_sql += " AND date(current_date) - date(d_cabinet_bodies.post_date) <= :limit_days "
    conditions_param[:limit_days] = @head.default_enable_day
    @cabinet_list = DCabinetBody.paginate(:page=>params[:page], :per_page=>@m_cabinet_setting.page_max_count, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)


    @total_size = 0  #使用容量(B)
    @cabinet_files = []
    join_sql = ""
    conditions_sql = " d_cabinet_files.delf = :delf "
    conditions_param[:delf] = "0"
    join_sql += " INNER JOIN d_cabinet_heads on d_cabinet_files.d_cabinet_head_id = d_cabinet_heads.id "
    conditions_sql += " AND d_cabinet_heads.delf = :delf "
    conditions_sql += " AND d_cabinet_heads.private_user_cd = :private_user_cd "
    conditions_param[:private_user_cd] = current_m_user.user_cd
    d_cabinet_files = DCabinetFile.find(:all, :joins=>join_sql, :conditions=>[conditions_sql, conditions_param])
    d_cabinet_files.each do |file|
      @cabinet_files[file.d_cabinet_body_id] = {:file_name=>file.file_name, :file_size=>file.file_size}
      @total_size += file.file_size
    end
    @total_size_mb = @total_size / 1024.0 / 1024.0  #使用容量(MB)
    @over_flg = 0 #容量オーバーフラグ(0:オーバーしていない, 1:オーバーしている)
    if @total_size_mb >= @head.max_disk_size
      @over_flg = 1
    end

#select *
#from d_cabinet_files
#inner join d_cabinet_heads
#  on d_cabinet_files.d_cabinet_head_id = d_cabinet_heads.id
#where d_cabinet_heads.private_user_cd = '0'
  end

  #
  # 詳細ダイアログの情報を取得します。
  #
  def dialog

    cabinet_id = params[:cabinet_id]

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND cabinet_kbn = :cabinet_kbn "
    conditions_param[:cabinet_kbn] = "0"
    conditions_sql += " AND private_user_cd = :private_user_cd "
    conditions_param[:private_user_cd] = current_m_user.user_cd
    @head = DCabinetHead.find(:first, :conditions=>[conditions_sql, conditions_param])

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_cabinet_head_id = :d_cabinet_head_id "
    conditions_param[:d_cabinet_head_id] = @head.id
    conditions_sql += " AND id = :id "
    conditions_param[:id] = cabinet_id
    @cabinet = DCabinetBody.find(:first, :order=>" post_date DESC ", :conditions=>[conditions_sql, conditions_param])

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_cabinet_body_id = :d_cabinet_body_id"
    conditions_param[:d_cabinet_body_id] = @cabinet.id
    @cabinet_file = DCabinetFile.find(:first, :conditions=>[conditions_sql, conditions_param])

    render :action=>"_dialog"
  end

  #
  # キャビネットに新規に保存します。
  #
  def create

    cabinet_head = DCabinetHead.get_cabinethead_by_user_cd current_m_user.user_cd
    cabinet_head_id = cabinet_head.id

    # 投稿内容の保存
    cabinet_body = DCabinetBody.new
    cabinet_body.d_cabinet_head_id = cabinet_head_id
    cabinet_body.title = params[:title]
    cabinet_body.body = params[:body]
    #cabinet_body.post_org_cd = current_m_user.org_cd
    cabinet_body.post_org_cd = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
    cabinet_body.post_user_cd = current_m_user.user_cd
    cabinet_body.post_user_name = current_m_user.name
    cabinet_body.post_date = Time.new
    cabinet_body.created_user_cd = current_m_user.user_cd
    cabinet_body.updated_user_cd = current_m_user.user_cd

    begin
      cabinet_body.save
      cabinet_head.lastpost_date = Time.now
      cabinet_head.lastpost_body_id = cabinet_body.id
      cabinet_head.save
    rescue
      #TODO エラー時の処理
    end

    # 添付ファイルの保存
    attachment = params[:attachment]
    next_page = ""
    unless attachment.nil?
      begin
        DCabinetFile.save_upload(params, current_m_user, cabinet_head_id, cabinet_body.id, "cabinet_mine")
        next_page = "alert('アップロードが完了しました');location.href='/cabinet/mine/index';"
      else
        # TODO エラー時の処理
      end
    else
      next_page = "location.href='/cabinet/mine/index'"
    end

    responds_to_parent do
      render :update do |page|
        page << next_page
      end
    end
  end

  #
  # 削除ボタンが押下されたときのアクション
  #
  def delete
    cabinet_id = params[:cabinet_id]

    conditions_sql = ""
    conditions_param = {}

    record = DCabinetBody.find(:first, :order=>'id', :conditions=>['id=?', cabinet_id])
    record.delf = '1'
    record.deleted_user_cd = current_m_user.id
    record.updated_user_cd = current_m_user.id
    record.deleted_at = Time.now

    begin
      record.save
      conditions_sql = " delf = :delf "
      conditions_param[:delf] = "0"
      conditions_sql += " AND d_cabinet_body_id = :d_cabinet_body_id "
      conditions_param[:d_cabinet_body_id] = cabinet_id
      file = DCabinetFile.find(:first, :conditions=>[conditions_sql, conditions_param])
      file.delf = "1"
      file.deleted_user_cd = current_m_user.user_cd
      file.updated_user_cd = current_m_user.user_cd
      file.updated_at = Time.now
      file.save
    rescue
      #TODO 例外発生時の処理
    end

    redirect_to :action => 'cabinet_list'
  end

  #
  # キャビネットファイルのダウンロード
  #
  def download
    file_rec = DCabinetFile.find(:first, :conditions=>{:d_cabinet_body_id=>params[:cabinet_id]})

    dirname = "#{RAILS_ROOT}/data/cabinet_mine/"

    send_file dirname + file_rec.real_file_name, :filename => file_rec.file_name.tosjis
  end
end
