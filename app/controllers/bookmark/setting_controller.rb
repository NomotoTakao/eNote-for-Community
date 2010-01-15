require 'hpricot'
require 'open-uri'

class Bookmark::SettingController < ApplicationController
  layout "portal", :except=>[:bookmark_list, :bookmark_delete, :new, :edit, :create, :update,
                   :dialog_category, :select_category, :dialog_category_detail, :dialog_category_register]

  skip_before_filter :verify_authenticity_token, :dialog_category_register

  def index
    #パンくずリストに表示させる
    @pankuzu += "リンク集の設定"

    #リンク集設定画面
    @categories = DBookmarkCategory.find(:all, :conditions => "delf = 0 AND public_flg = 0", :order => "sort_no")
    @bookmarks = []
  end

  #登録ダイアログ表示
  def new
    flash[:bookmark_err_msg] = ""
    target_url = params[:url]

    #入力されたリンクのURLが正しく開けるかチェック
    begin
      unless(open(target_url))
        flash[:bookmark_err_msg] = "URLが正しいか確認してください"
        return
      end
    rescue Exception
      flash[:bookmark_err_msg] = "URLが正しいか確認してください"
      return
    end

    begin
      doc = Hpricot open(URI.encode(target_url))
    rescue Exception
      flash[:bookmark_err_msg] = "URLが正しいか確認してください"
      return
    end

    title = ""  #タイトル
    description = ""  #コメント
    begin
      title = doc.search("title").first.inner_html
      doc.search("meta") do |t|
        description = t[:content] if t[:name] && t[:content] && t[:name].casecmp("description") == 0
      end
    rescue Exception
      title = ""
      description = ""
    end
    @bookmark = DBookmark.new
    @bookmark.d_bookmark_category_id = params[:categories]
    @bookmark.url = target_url
    @bookmark.title = bookmark_get_info_conv(title)
    @bookmark.memo = bookmark_get_info_conv(description)
  end

  #編集ダイアログ表示
  def edit
    flash[:bookmark_err_msg] = ""
    @bookmark = DBookmark.find(params[:id])
  end

  #登録
  def create
    begin
      #ブックマーク
      data = DBookmark.new
      data.d_bookmark_category_id = params[:bookmark]["categories"]
      data.title = bookmark_get_info_conv(params[:bookmark]["title"])
      data.url = params[:bookmark]["url"]
      data.public_flg = 0
      data.memo = bookmark_get_info_conv(params[:bookmark]["memo"])
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save
    rescue
      flash[:bookmark_err_msg] = "登録処理中に異常が発生しました。"
    end
    redirect_to :action => "index"
  end

  #更新
  def update
    begin
      #ブックマーク
      DBookmark.update(params[:bookmark]["id"], {:title=>params[:bookmark]["title"], :memo=>params[:bookmark]["memo"], :updated_user_cd=>current_m_user.user_cd})
    rescue
      flash[:bookmark_err_msg] = "更新処理中に異常が発生しました。"
    end
    redirect_to :action => "index"
  end

  #リンク集一覧の表示
  def bookmark_list
    @bookmarks = DBookmark.find(:all, :conditions => ["delf = 0 AND public_flg = 0 AND d_bookmark_category_id = ?", params[:category_id]],
    :order => "sort_no, id")
  end

  #リンク集の削除
  def delete
    begin
      rec = DBookmark.find(:first, :conditions => ["id = ?", params[:id]])
      rec.destroy
    rescue
      flash[:bookmark_err_msg] = "削除処理中に異常が発生しました。"
    end
    redirect_to :action => "index"
  end

  #
  # カテゴリ編集画面を取得するアクション
  #
  def dialog_category
    @categories = DBookmarkCategory.find(:all, :conditions => "delf = 0 AND public_flg = 0", :order => "sort_no")
  end

  #
  # 登録されているリンクカテゴリの一覧を取得するアクション
  #
  def select_category

    @categories = DBookmarkCategory.find(:all, :conditions => "delf = 0 AND public_flg = 0", :order => "sort_no")
  end

  #
  # カテゴリ編集ダイアログにおいて、選択されたカテゴリの詳細情報を取得するアクション
  #
  def dialog_category_detail
    id = params[:id]

    unless id.nil? or id.empty?
      @d_bookmark_category = DBookmarkCategory.find(:first, :conditions=>{:delf=>0, :id=>id});
    else
      @d_bookmark_category = DBookmarkCategory.new
    end
  end

  #
  # カテゴリ編集ダイアログボックスで、登録ボタンが押された時のアクション
  #
  def dialog_category_register
    id = params[:id]
    unless id.nil? or id.empty?
      # 更新・登録
      DBookmarkCategory.register(params, current_m_user.user_cd)
    end

    redirect_to :action=>:select_category
  end

  #
  # カテゴリ編集ダイアログボックスで、削除ボタンが押された時のアクション
  #
  def dialog_category_delete
    id = params[:id]
    unless id.nil? or id.empty?
      # 削除
      DBookmarkCategory.delete(params, current_m_user.user_cd)
    end

    redirect_to :action=>:select_category
  end

private
  # 文字列のエンコード変換＆整形
  def bookmark_get_info_conv str
    str = Kconv.toutf8 str
    str = str.strip
    str = str.gsub "\n", ""
    str = str.gsub "\t", " "
    str = str.gsub "　", " "
    str = str.gsub "  ", " "
    while str.include?("  ")
      str = str.gsub "  ", " "
    end
    return str
  end
end
