# encoding: utf-8
namespace :operate do
  desc "operate data"
  task(:data => :environment) do
    time_expression="TO_DAYS(NOW())-TO_DAYS(created_at)=1"
    register_num=User.count(:id, :conditions =>time_expression)
    action_num=ActionLog.count(:id, :conditions =>time_expression)
    web_buyer=Order.count(:id, :conditions =>time_expression)
    competes_buyer=Compete.count(:id, :conditions =>time_expression)
    buyers=web_buyer+competes_buyer
    fee_num=web_buyer*36+competes_buyer*10
    puts Statistic.find_by_created_at(1.day.ago.strftime("%Y-%m-%d"))
    Statistic.create(:register_num=>register_num,:action_num=>action_num,:pay_num=>buyers,:money_num=>fee_num,:created_at=>1.day.ago.strftime("%Y-%m-%d"))  unless Statistic.find_by_created_at(1.day.ago.strftime("%Y-%m-%d"))
  end
end

