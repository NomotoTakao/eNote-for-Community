class DBlogTag < ActiveRecord::Base
  belongs_to :d_blog_body
  
  #
  # ブログ詳細IDとカテゴリ名を指定して、タグのレコードを取得します。
  #
  # @param body_id  - ブログ詳細ID
  # @param category - カテゴリ名
  # @return 指定された記事のカテゴリレコード
  #
  def get_record_by_id_and_category body_id, category
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " d_blog_tags.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_blog_tags.d_blog_body_id = :body_id "
    conditions_param[:body_id] = body_id
    conditions_sql += " AND d_blog_tags.category = :category "
    conditions_param[:category] = category
    
    DBlogTag.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
  
  #
  # ブログ詳細IDを指定して、その記事に設定されているカテゴリの一覧を取得します。
  # 
  # @param id - ブログ詳細ID
  # @return カテゴリ一覧
  #
  def get_list_by_body_id id
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " d_blog_tags.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_blog_tags.d_blog_body_id = :id "
    conditions_param[:id] = id
    
    DBlogTag.find(:all, :conditions=>[conditions_sql, conditions_param])
  end
  
  # ブログ詳細IDに紐付くカテゴリを保存します。
  #
  # @param body_id    - ブログ詳細ID
  # @param categories - CSV形式のカテゴリ名
  # @param user_cd    - DBに登録する際に用いるユーザーCD
  #
  def save_category body_id, categories, user_cd
    arrayCategory = categories[0].split(",")
    # 渡されたIDで登録されているタグを検索する。
    tags = DBlogTag.new.get_list_by_body_id body_id
    
    # 登録されているタグと渡されたcategoryを比較しながら、登録を追加する。
    if tags.length == 0
      # 新規作成
      arrayCategory.each do |category|
        
        record = DBlogTag.new
        
        record.d_blog_body_id = body_id
        record.category = category
        record.created_user_cd = user_cd
        record.updated_user_cd = user_cd
        
        record.save
      end
    else
      # 登録されているカテゴリに対する操作
      tags.each do |tag|

        record = DBlogTag.new.get_record_by_id_and_category body_id, tag.category
        if record.nil?
          record = DBlogTag.new
          record.d_blog_body_id = body_id
          record.category = tag.category
          record.created_user_cd = user_cd
          record.updated_user_cd = user_cd
        else
          unless arrayCategory.include?(tag.category)
            record.delf = 1
            record.deleted_user_cd = user_cd
            record.deleted_at = Time.now
          end
        end
        record.save
      end
      # 新たに登録するカテゴリに対する操作
      arrayCategory.each do |category|
        record = DBlogTag.new.get_record_by_id_and_category body_id, category
        if record.nil?
          record = DBlogTag.new
          record.d_blog_body_id = body_id
          record.category = category
          record.created_user_cd = user_cd
          record.updated_user_cd = user_cd
          
          record.save
        end
      end
    end
  end
  
  #
  # 渡されたブログ詳細IDに紐づけられているカテゴリ情報のすべてに削除フラグを立てます。
  #
  # @param body_id - ブログ詳細ID
  # @param user_cd - 削除ユーザーCD
  #
  def delete body_id, user_cd
    
    record_list = DBlogTag.new.get_list_by_body_id body_id
    
    record_list.each do |record|
      
      record.delf = 1
      record.deleted_user_cd = user_cd
      record.deleted_at = Time.now
      
      record.save
    end
  end
  
  #
  # 投稿されたブログ記事に付けられたタグの統計情報を取得します。
  # 
  # @param user_cd - ユーザーCD
  # @return 統計情報(カテゴリ名と登録数)
  #
  def get_categorylist_with_count user_cd
    
    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = {}
    group_sql = ""
    order_sql = ""
    
    setting = MBlogSetting.find(:first);
    
    select_sql = " category, count(*)"
    
    joins_sql = " INNER JOIN d_blog_bodies ON d_blog_bodies.id = d_blog_tags.d_blog_body_id"
    joins_sql += " INNER JOIN d_blog_heads ON d_blog_heads.id = d_blog_bodies.d_blog_head_id "
    
    conditions_sql = " d_blog_tags.delf = :delf "
    conditions_sql += " AND d_blog_bodies.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_blog_bodies.public_flg = :public_flg"
    conditions_param[:public_flg] = 0
    conditions_sql += " AND d_blog_heads.user_cd = :user_cd"
    conditions_param[:user_cd] = user_cd
    
    order_sql = " count DESC"
    
    group_sql = " category"
    
    DBlogTag.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :group=>group_sql, :order=>order_sql, :limit=>setting.page_max_count)
  end
  
end
