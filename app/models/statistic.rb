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


  


end

