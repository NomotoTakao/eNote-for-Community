class Bulletin::MainController < ApplicationController
  layout "portal", :except=>[:bulletin_list, :list, :new_tab, :new, :detail, :download, :delete_file, :_attachment_file]

  def index
    #パンくずリストに表示させる
    @pankuzu += "回覧板"
    #指定フォルダ(0:未読, 1:既読, 2:期限切れ, 3:自分が作成したもの, 9:あいまい検索)
    @kbn_id = 0
    if !params[:kbn_id].nil? && params[:kbn_id] != ""
      @kbn_id = params[:kbn_id].to_i
    end
  end

  def list
    #未読の件数を取得
    @unread_count = DBulletinBody.get_mybulletin(current_m_user.user_cd, 0, "").size
    @kbn_id = params[:kbn_id]
  end

  #回覧板一覧を表示（状態区分で抽出）
  def bulletin_list
    @bulletins = DBulletinBody.get_mybulletin(current_m_user.user_cd, params[:kbn_id], params[:sword])
    @edit_id = params[:edit_id]
    @kbn_id = params[:kbn_id]
  end

  def detail
    @bulletin_head = DBulletinHead.find(:first, :conditions => ["id = ?", params[:id]])
    @bulletin_body = DBulletinBody.find(:first, :conditions => ["user_cd = ? AND d_bulletin_head_id = ?", current_m_user.user_cd, @bulletin_head.id])
    if @bulletin_head.answer_public_kbn == 1 or @bulletin_head.post_user_cd == current_m_user.user_cd
      @bulletin_bodies = @bulletin_head.d_bulletin_bodies
    end
  end

  def new_tab

  end

  #回覧板の新規作成画面
  def new
    edit_id = params[:edit_id]

    if edit_id.nil? or edit_id.empty?
      @bulletin_head = DBulletinHead.new
    else
      @bulletin_head = DBulletinHead.find(:first, :conditions=>{:delf=>0, :id=>edit_id})
    end
    @bulletin_head.post_user_cd = current_m_user.user_cd
    @bulletin_head.post_user_name = current_m_user.name
  end

  #回覧板の新規保存・編集
  def create
    head_id = params[:d_bulletin_head][:id]
    if head_id.nil? or head_id.empty?
      @bulletin_head = DBulletinHead.new(params[:bulletin_head])
      @bulletin_head.created_user_cd = current_m_user.user_cd
    else
      @bulletin_head = DBulletinHead.find(:first, :conditions=>{:delf=>0, :id=>head_id})
      @bulletin_head.title = params[:bulletin_head][:title]
      @bulletin_head.bulletin_date_from = params[:bulletin_head][:bulletin_date_from]
      @bulletin_head.bulletin_date_to = params[:bulletin_head][:bulletin_date_to]
      @bulletin_head.answer_public_kbn = params[:bulletin_head][:answer_public_kbn]
      @bulletin_head.body = params[:bulletin_head][:body]

    end
    @bulletin_head.updated_user_cd = current_m_user.user_cd
    @bulletin_head.save

    user_cds = params[:decided_user_cds].split(",")
    user_cds.each do |user_cd|
      unless head_id.empty?
        bulletin_body = DBulletinBody.find(:first, :conditions=>{:delf=>0, :d_bulletin_head_id=>head_id, :user_cd=>user_cd})
      end

      if bulletin_body.nil?
        bulletin_body = DBulletinBody.new
        bulletin_body.d_bulletin_head_id = @bulletin_head.id
        bulletin_body.user_cd = user_cd
        bulletin_body.answer_kbn = 0
        bulletin_body.created_user_cd = current_m_user.user_cd
      end
      bulletin_body.updated_user_cd = current_m_user.user_cd
      bulletin_body.save

      # 各々のユーザーのMyページの新着メッセージを登録する。
      unless head_id.empty?
        message = DMessage.find(:first, :conditions=>{:delf=>0, :user_cd=>user_cd, :etctxt1=>"bulletin_head_id_"+head_id})
      end

      if message.nil?
        message = DMessage.new
        message.user_cd = user_cd
        message.message_kbn = 0 #TODO これでよい？
        message.from_user_cd = current_m_user.user_cd
        message.from_user_name = current_m_user.name
        message.title = "&lt;回覧板&gt;"
        message.body = "[#{@bulletin_head.title}]が回覧されています。"
        message.post_date = Time.now
        message.etctxt1 = "bulletin_head_id_" + @bulletin_head.id.to_s
        message.created_user_cd = current_m_user.user_cd
      end

      message.updated_user_cd = current_m_user.user_cd
      message.updated_at = Time.now
      message.save
    end

    #作成した自分自身は必ず含めるものとする
    unless user_cds.include?(current_m_user.user_cd)
      bulletin_body = DBulletinBody.new
      bulletin_body.d_bulletin_head_id = @bulletin_head.id
      bulletin_body.user_cd = current_m_user.user_cd
      bulletin_body.answer_kbn = 0
      bulletin_body.created_user_cd = current_m_user.user_cd
      bulletin_body.updated_user_cd = current_m_user.user_cd
      bulletin_body.save
    end


    # 添付ファイルの保存
    attachment = params[:attachment]
    next_page = ""
    unless attachment.nil?
      begin
        DBulletinFile.save_upload(params, current_m_user, @bulletin_head.id)
        next_page = "alert('アップロードが完了しました');location.href='/bulletin/main';"
      else
        # TODO エラー時の処理
      end
    else
      next_page = "location.href='/bulletin/main'"
    end

    responds_to_parent do
      render :update do |page|
        page << next_page
      end
    end


#    redirect_to "/bulletin/main"
  end

  #回覧板の確認時の更新
  def checked
    bulletin_body = DBulletinBody.find(params[:bulletin_body][:id])
    bulletin_body.answer_kbn = 1
    bulletin_body.answer_date = DateTime.now
    bulletin_body.comment = params[:bulletin_body][:comment]
    bulletin_body.created_user_cd = current_m_user.user_cd
    bulletin_body.save

    redirect_to "/bulletin/main"
  end

  #
  # 添付ファイルのアイコンがクリックされた時のアクション
  #
  def download

    file_id = params[:id]

    file_rec = DBulletinFile.new.find_by_id file_id

    dirname = "#{RAILS_ROOT}/data/bulletin/"

    send_file dirname + file_rec.real_file_name, :filename => file_rec.file_name.tosjis
  end

  #
  # 編集
  #
  def edit
    edit_id = params[:id]

    redirect_to :action=>:bulletin_list, :kbn_id=>0, :edit_id=>edit_id
  end

  #
  # 削除
  #
  def delete
    id = params[:id]
    kbn_id = params[:kbn_id]
    d_bulletin_heads = DBulletinHead.find(:first, :conditions=>{:delf=>0, :id=>id})
    unless d_bulletin_heads.nil?
      begin
        # 添付ファイルがある場合、削除する。
        if d_bulletin_heads.d_bulletin_file.length > 0
          d_bulletin_heads.d_bulletin_file.each do |d_bulletin_file|
            d_bulletin_file.delf = 1
            d_bulletin_file.deleted_user_cd = current_m_user.user_cd
            d_bulletin_file.deleted_at = Time.now
            d_bulletin_file.save
          end
        end

        # bodyを削除する。
        if d_bulletin_heads.d_bulletin_bodies.length > 0
          d_bulletin_heads.d_bulletin_bodies.each do |d_bulletin_body|
            d_bulletin_body.delf = 1
            d_bulletin_body.deleted_user_cd = current_m_user.user_cd
            d_bulletin_body.deleted_at = Time.now
            d_bulletin_body.save
          end
        end

        # メッセージを削除
        d_messages = DMessage.find(:all, :conditions=>{:delf=>0, :etctxt1=>"bulletin_head_id_"+d_bulletin_heads.id.to_s})
        unless d_messages.nil?
          d_messages.each do |message|
            message.delf = 1
            message.deleted_user_cd = current_m_user.user_cd
            message.deleted_at = Time.now
            message.save
          end
        end

        # headを削除#
        d_bulletin_heads.delf = 1
        d_bulletin_heads.deleted_user_cd = current_m_user.user_cd
        d_bulletin_heads.deleted_at = Time.now
        d_bulletin_heads.save
      end
    end

    redirect_to :action=>:index, :kbn_id=>kbn_id
  end

  #
  # 添付ファイルの削除をおこなう
  #
  def delete_file
    head_id = params[:head_id]
    file_id = params[:file_id]

    d_bulletin_files = DBulletinFile.find(:first, :conditions=>{:delf=>0, :id=>file_id})
    unless d_bulletin_files.nil?
      d_bulletin_files.delf = 1
      d_bulletin_files.deleted_user_cd = current_m_user.user_cd
      d_bulletin_files.deleted_at = Time.now
      begin
        d_bulletin_files.save
      end
    end

    @bulletin_head = DBulletinHead.find(:first, :conditions=>{:delf=>0, :id=>head_id})

    render :action=>:_attachment_file
  end
end
