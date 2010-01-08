class Bookmark::MainController < ApplicationController
  layout "portal", :except=>[:bookmark_list, :bookmark_search]

  def index
    #パンくずリストに表示させる
    @pankuzu += "リンク集"

    @categories = DBookmarkCategory.find(:all, :conditions => "delf = 0 AND public_flg = 0", :order => "sort_no")
  end

  #ブックマーク一覧を表示（カテゴリーIDで抽出）
  def bookmark_list
    @bookmarks = DBookmark.find(:all, :conditions => ["delf = 0 AND public_flg = 0 AND d_bookmark_category_id = ?", params[:category_id]], :order => "sort_no, id")
  end

  #ブックマーク一覧を表示（あいまい検索）
  def bookmark_search
    sql = "delf = 0 AND public_flg = 0 "
    sql += " AND (title LIKE '%#{params[:sword]}%' OR memo LIKE '%#{params[:sword]}%') "
    @bookmarks = DBookmark.find(:all, :conditions => sql, :order => "d_bookmark_category_id, sort_no, id")
    render :action => "bookmark_list"
  end

end
