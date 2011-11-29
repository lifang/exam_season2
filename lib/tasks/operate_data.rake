# encoding: utf-8
namespace :operate do
  desc "rate paper"
  task(:data => :environment) do
    time_expression="TO_DAYS(NOW())-TO_DAYS(created_at)=1"
    register_num=User.find_by_sql("select count(*) ids from users where #{time_expression}")[0].ids
    action_num=ActionLog.find_by_sql("select count(*) ids from action_logs where #{time_expression}")[0].ids
    web_buyer=Order.find_by_sql("select count(*) ids from orders where #{time_expression}")[0].ids
    competes_buyer=Compete.find_by_sql("select count(*) ids from competes where #{time_expression}")[0].ids
    buyers=web_buyer+competes_buyer
    fee_num=web_buyer*36+competes_buyer*10
    Statistic.create(:register_num=>register_num,:action_num=>action_num,:pay_num=>buyers,:money_num=>fee_num,:created_at=>1.day.ago)
  end
end

