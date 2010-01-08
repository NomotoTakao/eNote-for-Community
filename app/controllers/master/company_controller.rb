require "date"
class Master::CompanyController < ApplicationController
  layout "portal"
  PANKUZU = "会社マスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
    #会社マスタ
    @m_companies = MCompany.get_company_all_list[0]
    if @m_companies.nil?
      @m_companies = MCompany.new
    end
    #更新結果
    @result = params[:result]
  end

  #更新処理
  def update
    begin
      #処理結果
      @result = 99

      #会社マスタ
      #削除
      MCompany.delete_all(params[:m_companies_id])

      #追加
      data = MCompany.new(params[:m_companies])
      data.delf = 0
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save
      @result = 1

    rescue => ex
      flash[:company_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MCompany Err => #{ex}"
    end
    redirect_to :action => "index", :result => @result
  end
end