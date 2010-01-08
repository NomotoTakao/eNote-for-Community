class MCustomerEmployee < ActiveRecord::Base

  #
  #
  #
  def self.register params

    unless params[:m_customer_employees].nil?

      m_customer_employee = find(:first, :conditions=>{:delf=>0, :user_cd=>params[:m_customer_employees][:user_cd]})
      if m_customer_employee.nil?
        m_customer_employee = MCustomerStaff.new
        m_customer_employee.user_cd = params[:m_customer_employees][:user_cd]
        m_customer_employee.created_user_cd = params[:m_customer_employees][:created_user_cd]
      end
      unless params[:m_customer_employees][:name].nil?
        m_customer_employee.name = params[:m_customer_employees][:name]
      end
      unless params[:m_customer_employees][:name_kana].nil?
        m_customer_employee.name_kana = params[:m_customer_employees][:name_kana]
      end
      unless params[:m_customer_employees][:company_cd].nil?
        m_customer_employee.company_cd = params[:m_customer_employees][:company_cd]
      end
      unless params[:m_customer_employees][:post_name].nil?
        m_customer_employee.post_name = params[:m_customer_employees][:post_name]
      end
      unless params[:m_customer_employees][:position_name].nil?
        m_customer_employee.position_name = params[:m_customer_employees][:position_name]
      end
      unless params[:m_customer_employees][:etcint1].nil?
        m_customer_employee.etcint1 = params[:m_customer_employees][:etcint1]
      end
      unless params[:m_customer_employees][:etcint2].nil?
        m_customer_employee.etcint2 = params[:m_customer_employees][:etcint2]
      end
      unless params[:m_customer_employees][:etcdec1].nil?
        m_customer_employee.etcdec1 = params[:m_customer_employees][:etcdec1]
      end
      unless params[:m_customer_employees][:etcdec2].nil?
        m_customer_employee.etcdec2 = params[:m_customer_employees][:etcdec2]
      end
      unless params[:m_customer_employees][:etcstr1].nil?
        m_customer_employee.etcstr1 = params[:m_customer_employees][:etcstr1]
      end
      unless params[:m_customer_employees][:etcstr2].nil?
        m_customer_employee.etcstr2 = params[:m_customer_employees][:etcstr2]
      end
      unless params[:m_customer_employees][:etctxt1].nil?
        m_customer_employee.etctxt1 = params[:m_customer_employees][:etctxt1]
      end
      unless params[:m_customer_employees][:etctxt2].nil?
        m_customer_employee.etctxt2 = params[:m_customer_employees][:etctxt2]
      end
      unless params[:m_customer_employees][:updated_user_cd].nil?
        m_customer_employee.updated_user_cd = params[:m_customer_employees][:updated_user_cd]
      end

      begin
        m_customer_employee.save!
      rescue
        p $!
        raise
      end
    end
  end

end
