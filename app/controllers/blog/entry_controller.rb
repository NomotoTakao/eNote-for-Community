class Blog::EntryController < ApplicationController
  layout "portal", :except=>[:article_create, :article_edit, :delete, :created]

  #
  # ブログ記事の新規作成・更新をおこないます。
  #
  def created

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    conditions_sql += " AND user_cd = :user_cd "
    conditions_param[:user_cd] = current_m_user.user_cd
    m_tag = params[:categories]

    # ブログヘッダを取得する。
    blog_head = DBlogHead.find(:first, :conditions=>[conditions_sql, conditions_param])
    if blog_head.nil?
      # ヘッダを作る
      DBlogHead.new.create_blog_head current_m_user.user_cd
      blog_head = DBlogHead.find(:first, :conditions=>[conditions_sql, conditions_param])
    end
    # 「公開する」チェックボックスの状態を受け取る。0:公開、1:非公開。チェックが入れられた場合は"1"が取得されるので、DB登録時には反転させる。
    public_flg = params[:d_blog_body][:public_flg]
    if public_flg != "on"
      public_flg = "1"
    else
      public_flg = "0"
    end

    if params[:blog_edit_flag].empty?
      @blog_article = DBlogBody.new(params[:d_blog_body])
      @blog_article.d_blog_head_id = blog_head.id
      @blog_article.public_flg = public_flg
      # 役員の場合、top_disp_kbnに'0'をセットする。
      unless (MUserAttribute.new.check_user_is_director current_m_user.user_cd).nil?
        @blog_article.top_disp_kbn = 0
      end
      @blog_article.post_date = Time.now
      @blog_article.delf = "0"
      @blog_article.created_user_cd = current_m_user.user_cd
      @blog_article.updated_user_cd = current_m_user.user_cd

    else
      @blog_article = DBlogBody.new.get_article_by_id params[:blog_edit_flag]
      @blog_article.public_flg = public_flg
      @blog_article.update_attributes(params[:d_blog_body])
      @blog_article.public_flg = public_flg
    end

    @blog_article.save

    # カテゴリを登録する。
    DBlogTag.new.save_category @blog_article.id, m_tag, current_m_user.user_cd


    redirect_to :controller => 'view', :action => 'top'
  end

  #
  # 受け取ったIDの記事を削除します。
  #
  def delete

    @blog_article = DBlogBody.new.get_article_by_id params[:id]

    #ユーザーチェック
    if @blog_article.created_user_cd != current_m_user.user_cd
      redirect_to :controller => 'view', :action => 'detail', :id => params[:id]
      return false
    end

    @blog_article.delf = "1"
    @blog_article.deleted_at = Time.now
    @blog_article.save

    DBlogTag.new.delete @blog_article.id, current_m_user.user_cd

    redirect_to :controller => 'view', :action => 'blog_list'

  end

  #
  # 「新規投稿」ボタンが押下された時のアクション
  #
  def article_create

    @d_blog_body = DBlogBody.new
  end

  #
  # 編集画面を表示するときのアクション
  #
  def article_edit
    @d_blog_body = DBlogBody.new.get_article_by_id params[:id]
    @blog_edit_flag = params[:id]
  end

  #
  # 「お気に入りブログ」を追加するときのアクション
  #
  def favorite_create

    head_id = params[:head_id]

    DBlogFavorite.new.add_favorite head_id, current_m_user

    redirect_to :controller=>"view", :action=>"menu_favorite_list"
  end

  #
  # 指定されたお気に入りを削除します(削除フラグを'1'にします)
  #
  def favorite_delete

    favorite_id = params[:favorite_id]

    DBlogFavorite.new.delete_favorite favorite_id, current_m_user

    redirect_to :controller=>"view", :action=>"menu_favorite_list"
  end
end
