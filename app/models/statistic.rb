# encoding: utf-8
class Statistic< ActiveRecord::Base

def self.user_expr(types)
     if types.to_i==1
      file_name="/#{Time.now.to_date.to_s}_user_all.xls"
    elsif types.to_i==2
      file_name="/#{Time.now.to_date.to_s}_user_30.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    elsif types.to_i==3
      file_name="/#{Time.now.to_date.to_s}_user_7.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=7 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    else
      file_name="/#{Time.now.to_date.to_s}_user_1.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(created_at)=1"
    end
    return [file_name,expression]
  end


  def self.download_expr(types,action,other)
     if types.to_i==1
      file_name="/#{Time.now.to_date.to_s}_#{action}_all.xls"
      expression=" where #{other}"
    elsif types.to_i==2
      file_name="/#{Time.now.to_date.to_s}_#{action}_30.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1 and  #{other}"
    elsif types.to_i==3
      file_name="/#{Time.now.to_date.to_s}_#{action}_7.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=7 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1 and  #{other}"
    else
      file_name="/#{Time.now.to_date.to_s}_#{action}_1.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(created_at)=1 and #{other}"
    end
    return [file_name,expression]
  end

  def self.download_info(types)
    if types.to_i==1
      file_name="/#{Time.now.to_date.to_s}_buyer_all.xls"
    elsif types.to_i==2
      file_name="/#{Time.now.to_date.to_s}_buyer_30.xls"
      expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    elsif types.to_i==3
      file_name="/#{Time.now.to_date.to_s}_buyer_7.xls"
      expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=7 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    elsif types.to_i==4
      file_name="/#{Time.now.to_date.to_s}_buyer_1.xls"
      expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)=1"
    elsif types.to_i==5
      file_name="/#{Time.now.to_date.to_s}_fee_all.xls"
    elsif types.to_i==6
      file_name="/#{Time.now.to_date.to_s}_fee_30.xls"
      expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    elsif types.to_i==7
      file_name="/#{Time.now.to_date.to_s}_fee_7.xls"
      expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=7 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    elsif types.to_i==8
      file_name="/#{Time.now.to_date.to_s}_fee_1.xls"
      expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)=1"
    end
    return [file_name,expr]
  end

  def self.exam_user_count(id)
    count_num=[]
    one_expr=" TO_DAYS(NOW())-TO_DAYS(created_at)=1 and examination_id=#{id}"
    count_num << ExamUser.count(:id, :conditions =>one_expr)
    three_expr="TO_DAYS(NOW())-TO_DAYS(created_at)<=3 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1 and examination_id=#{id}"
    count_num << ExamUser.count(:id, :conditions =>three_expr)
    all_expr="examination_id=#{id}"
    count_num << ExamUser.count(:id, :conditions =>all_expr)
    return count_num
  end
  


end

