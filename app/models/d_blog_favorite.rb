class DBlogFavorite < ActiveRecord::Base
  belongs_to :d_blog_head
  
  #
  # 指定されたユーザーのお気に入りリストを取得します。
  #
  # @param user_cd - ユーザーコード
  # @return 指定されたユーザーのお気に入り一覧
  #
  def get_favorite_list user_cd
    
    conditions_sql = ""
    conditions_param = {}
    order_sql = ""
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND user_cd = :user_cd"
    conditions_param[:user_cd] = user_cd
    
    order_sql = " order_display ASC "
    
    DBlogFavorite.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end
  
  #
  # 指定されたユーザーの、指定されたブログヘッダIDのお気に入りを取得します
  #
  # @param head_id - ブログヘッダID
  # @param user_cd - ユーザーコード
  # @return 指定されたお気に入りのレコード。見つからない場合はnil。
  #
  def get_favorite_by_head_id head_id, user_cd
    
    conditions_sql = ""
    conditions_param = {}
    
#    conditions_sql = " delf = :delf "
#    conditions_param[:delf] = 0
    conditions_sql += " d_blog_head_id = :d_blog_head_id "
    conditions_param[:d_blog_head_id] = head_id
    conditions_sql += " AND user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd
    
    DBlogFavorite.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
  
  #
  # お気に入りを追加します。
  #
  # @param head_id - ブログヘッダID
  # @param user - ログインユーザーオブジェクト
  #
  def add_favorite head_id, user
    
    # お気に入りに既に含まれていないかをチェック
    d_blog_favorite = DBlogFavorite.new.get_favorite_by_head_id head_id, user.user_cd
    
    if d_blog_favorite.nil?
      # 含まれていない場合は新規登録
      d_blog_favorite = DBlogFavorite.new
      d_blog_favorite.user_cd = user.user_cd
      d_blog_favorite.d_blog_head_id = head_id
      d_blog_favorite.created_user_cd = user.user_cd
      d_blog_favorite.updated_user_cd = user.user_cd
      d_blog_favorite.order_display = (DBlogFavorite.new.get_favorite_list user.user_cd).length

      d_blog_favorite.save
    elsif d_blog_favorite.delf == 1
      # 削除状態のときは、削除フラグを'0'に変更する。
      d_blog_favorite.delf = 0
      d_blog_favorite.deleted_user_cd = nil
      d_blog_favorite.deleted_at = nil
      d_blog_favorite.updated_user_cd = user.user_cd
      
      d_blog_favorite.save
    end
  end
  
  #
  # お気に入りを削除します
  #
  # @param favorite_id - お気に入りヘッダID
  # @param user - ユーザーオブジェクト
  #
  def delete_favorite favorite_id, user
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND id = :id "
    conditions_param[:id] = favorite_id
    
    d_blog_favorite = DBlogFavorite.find(:first, :conditions=>[conditions_sql, conditions_param])
    
    unless d_blog_favorite.nil?
      d_blog_favorite.delf = 1
      d_blog_favorite.deleted_user_cd = user.user_cd
      
      d_blog_favorite.save
    end
    
  end
end
