class Master::LogController < ApplicationController
  layout "portal",
  :except=>[:log_list]
  
  # ログ一覧に表示する、1ページ当たりの件数
  PER_PAGE = 10
  
  def index
    
    #パンくずリストに表示させる
    @pankuzu += "ログ閲覧"
  end
  
  def log_list
    
    # 一覧ヘッダ部の▲/▼の制御はmodelで行えない(変数の授受ができない。)ので、controllerで行う。
    order = params[:order]
    mode = params[:mode]
    
    unless order.nil?
      if order == "created_at"
        if mode == "2"
          next_mode = "1"
        else
          next_mode = "2"
        end
        @next_mode_created_at = next_mode
      elsif order == "created_user_cd"
        if mode == "2"
          next_mode = "1"
        else
          next_mode = "2"
        end
        @next_mode_created_user_cd = next_mode
      elsif order == "table_name"
        if mode == "2"
          next_mode = "1"
        else
          next_mode = "2"
        end
        @next_mode_table_name = next_mode
      elsif order == "manipulate_id"
        if mode == "2"
          next_mode = "1"
        else
          next_mode = "2"
        end
        @next_mode_manipulate_id = next_mode
      elsif order == "manipulate_name"
        if mode == "2"
          next_mode = "1"
        else
          next_mode = "2"
        end
        @next_mode_manipulate_name = next_mode
      end
      
      # paginateのために、パラメータをインスタンス変数に展開
      @date_from = params[:date_from]
      @date_to = params[:date_to]
      @manipulate_user_name = params[:manipulate_user_name]
      @table_name = params[:table_name]
      @manipulate_id = params[:manipulate_id]
      @manipulate_name = params[:manipulate_name]
      @order = params[:order]
      @mode = params[:mode]
    else
      @next_mode_created_at = "2"
    end
    
    # ログ一覧を取得する
    @log_list = DLog.find_for_paginate(params, PER_PAGE)

  end
end
