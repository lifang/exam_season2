# encoding: utf-8
namespace :operate do
  desc "operate data"
  task(:data => :environment) do
    TIME_EXPRESSION=" TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    seven_expr=" TO_DAYS(NOW())-TO_DAYS(created_at)<=7 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    one_expr=" TO_DAYS(NOW())-TO_DAYS(created_at)=1"
    num=[]
    detail=[]
    new=[]
    detail<< User.count(:id)
    detail << User.count(:id, :conditions =>TIME_EXPRESSION)
    detail << User.count(:id, :conditions =>seven_expr)
    detail << User.count(:id, :conditions =>one_expr)
    num << detail.shift(4).join(",")
    detail << ActionLog.sum(:total_num)
    detail << ActionLog.sum(:total_num, :conditions =>TIME_EXPRESSION)
    detail << ActionLog.sum(:total_num, :conditions =>seven_expr)
    detail << ActionLog.sum(:total_num, :conditions =>one_expr)
    num << detail.shift(4).join(",")
    detail<< Order.count(:id)
    detail << Order.count(:id, :conditions =>TIME_EXPRESSION)
    detail << Order.count(:id, :conditions =>seven_expr)
    detail << Order.count(:id, :conditions =>one_expr)
    detail << Compete.count(:id)
    detail << Compete.count(:id, :conditions =>TIME_EXPRESSION)
    detail << Compete.count(:id, :conditions =>seven_expr)
    detail << Compete.count(:id, :conditions =>one_expr)
    new << detail.slice!(0)+detail[3]
    new << detail.slice!(0)+detail[3]
    new << detail.slice!(0)+detail[3]
    new << detail.slice!(0)+detail[3]
    num << new.shift(4).join(",")
    detail << Order.sum(:total_price)
    detail << Order.sum(:total_price, :conditions =>TIME_EXPRESSION)
    detail << Order.sum(:total_price, :conditions =>seven_expr)
    detail << Order.sum(:total_price, :conditions =>one_expr)
    new << detail.slice!(0)*10+detail.slice!(3)
    new << detail.slice!(0)*10+detail.slice!(2)
    new << detail.slice!(0)*10+detail.slice!(1)
    new << detail.slice!(0)*10+detail.slice!(0)
    num << new.shift(4).join(",")
    detail << ActionLog.sum(:total_num,:conditions =>"types=0")
    detail << ActionLog.sum(:total_num, :conditions =>TIME_EXPRESSION+" and types=0")
    detail << ActionLog.sum(:total_num, :conditions =>seven_expr+" and types=0")
    detail << ActionLog.sum(:total_num, :conditions =>one_expr+" and types=0")
    num << detail.shift(4).join(",")
    attrs={:register=>num[0],:action=>num[1],:pay=>num[2],:money=>num[3],:created_at=>1.day.ago.strftime("%Y-%m-%d"),:login=>num[4]}
    stat=Statistic.find_by_created_at(1.day.ago.strftime("%Y-%m-%d"))
    if stat.nil?
      Statistic.create(attrs)
      puts "create success"
    else
      stat.update_attributes(attrs)
      puts "update success"
    end
  end
end

