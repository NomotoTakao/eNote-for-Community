class DBookmarkCategory < ActiveRecord::Base

  #
  # カテゴリの新規登録・更新
  #
  def self.register params, user_cd

    id = params[:id]

    unless id.nil? or id.empty? or id == "null"
      # 更新
      d_bookmark_category = DBookmarkCategory.find(:first, :conditions=>{:delf=>0, :id=>id})
      unless d_bookmark_category.nil?
        d_bookmark_category.title = params[:title]
        d_bookmark_category.memo = params[:memo]
        d_bookmark_category.updated_user_cd = user_cd
        begin
          d_bookmark_category.save!
        rescue
          # 例外が発生した場合は、原因を出力し上位モジュールへ投げる。
          p $!
          raise
        end
      end
    else
      # 新規登録
      d_bookmark_category = DBookmarkCategory.new
      d_bookmark_category.title = params[:title]
      d_bookmark_category.memo = params[:memo]
      d_bookmark_category.sort_no = DBookmarkCategory.maximum("sort_no").to_i + 1
      d_bookmark_category.created_user_cd = user_cd
      d_bookmark_category.updated_user_cd = user_cd
      begin
        d_bookmark_category.save!
      rescue
        p $!
        raise
      end
    end
  end

  #
  # カテゴリの削除
  #
  def self.delete params, user_cd

    id = params[:id]

    unless id.nil? or id.empty?
      d_bookmark_category = DBookmarkCategory.find(:first, :conditions=>{:delf=>0, :id=>id})
      unless d_bookmark_category.nil?
        d_bookmark_category.delf = "1"
        d_bookmark_category.deleted_user_cd = user_cd
        d_bookmark_category.deleted_at = Time.now
        begin
          d_bookmark_category.save!
        rescue
          # 例外が発生した場合は、原因を出力し上位モジュールへ投げる。
          p $!
          raise
        end
      end
    end
  end
end
