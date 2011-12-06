# encoding: utf-8
class Statistic< ActiveRecord::Base
  TIME_EXPRESSION=" TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
  def self.count_num
    num=[]
    num << User.count(:id)
    num << User.count(:id, :conditions =>TIME_EXPRESSION)
    num << ActionLog.count(:id)
    num << ActionLog.count(:id, :conditions =>TIME_EXPRESSION)
    num << Order.count(:id)
    num << Order.count(:id, :conditions =>TIME_EXPRESSION)
    num << Order.sum(:total_price)
    num << Order.sum(:total_price, :conditions =>TIME_EXPRESSION)
    num << Compete.count(:id)
    num << Compete.count(:id, :conditions =>TIME_EXPRESSION)
    return num
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

