class DCompanyAddress < ActiveRecord::Base
  
  #
  # 取引先を検索する。
  #
  # @param kbn - 取引先区分(1:得意先、2:メーカー、3:取引先)
  # @param keyword - 会社コードまたは会社名の一部
  # @return 取引先一覧
  #
  def self.get_customer_list kbn, keyword
    
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""
        
    conditions_sql = " d_company_addresses.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_company_addresses.company_kbn = :company_kbn "
    conditions_param[:company_kbn] = kbn
    conditions_sql += " AND (d_company_addresses.company_cd like :keyword OR d_company_addresses.name like :keyword OR d_company_addresses.name_kana like :keyword OR d_company_addresses.name_short like :keyword)"
    conditions_param[:keyword] = "%" + keyword + "%"
    order_sql = " d_company_addresses.company_cd ASC "
    
    return DCompanyAddress.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

end
