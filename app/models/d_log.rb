class DLog < ActiveRecord::Base
  
  #
  # ページネーション機能を考慮して、ログを取得する。
  #
  # @param params - ブラウザから取得したリクエストのハッシュテーブル
  # @param max_count - 一度に取得する最大件数
  #
  def self.find_for_paginate params, max_count
    
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = "created_at DESC"
    
    unless params[:date_from].empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end
      conditions_sql += " date_trunc('day', created_at) >= :date_from"
      conditions_param[:date_from] = params[:date_from]
    end
    
    unless params[:date_to].empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end
      conditions_sql += " date_trunc('day', created_at) <= :date_to"
      conditions_param[:date_to] = params[:date_to]
    end
    
    unless params[:manipulate_user_name].empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end
      # 入力されたユーザーのユーザーをマスタから探す。複数存在する場合はそのすべてを取得する。
      users = MUser.get_user_by_name(params[:manipulate_user_name])
      unless users.nil?
        tmp_conditions_sql = ""
        users.each do |user|
          unless tmp_conditions_sql.empty?
            tmp_conditions_sql += " OR "
          end
          
          tmp_conditions_sql += "created_user_cd = '" + user.user_cd + "'"
        end
        conditions_sql += "(" + tmp_conditions_sql + ")"
      else
        conditions_sql += " created_user_cd = :user_cd"
        conditions_param[:user_cd] = ""
      end
      
    end
    
    unless params[:table_name].empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end
      conditions_sql += " table_name like :table_name"
      conditions_param[:table_name] = "%" + params[:table_name] + "%"
    end
    
    unless params[:manipulate_id].empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end
      conditions_sql += " manipulate_id = :manipulate_id"
      conditions_param[:manipulate_id] = params[:manipulate_id]
    end
    
    unless params[:manipulate_name].empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end
      conditions_sql += " manipulate_name = :manipulate_name"
      conditions_param[:manipulate_name] = params[:manipulate_name]
    end
    
    unless params[:order].nil?
      order_sql = params[:order]
      if params[:mode] == "2"
        order_sql += " ASC"
      else
        order_sql += " DESC"
      end
    end
#@next_mode_manipulate_name = 1
    DLog.paginate(:page=>params[:page], :per_page=>max_count, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end
end
