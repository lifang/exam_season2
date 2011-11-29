# encoding: utf-8
class StatisticData< ActiveRecord::Base
  TIME_EXPRESSION=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"

  def self.register_num
    num={}
    num["0"]=User.find_by_sql("select count(*) ids from users #{TIME_EXPRESSION}")
    num["1"]=User.find_by_sql("select count(*) ids from users")
    return num
  end

  def self.action_num
    num={}
    num["0"]=ActionLog.find_by_sql("select count(*) ids from action_logs #{TIME_EXPRESSION}")
    num["1"]=ActionLog.find_by_sql("select count(*) ids from action_logs")
    return num
  end


  def self.web_buyer_num
    num={}
    num["0"]=Order.find_by_sql("select count(*) ids from orders #{TIME_EXPRESSION}")
    num["1"]=Order.find_by_sql("select count(*) ids from orders")
    return num
  end

  def self.competes_buyer_num
    num={}
    num["0"]=Compete.find_by_sql("select count(*) ids from competes #{TIME_EXPRESSION}")
    num["1"]=Compete.find_by_sql("select count(*) ids from competes")
    return num
  end


end

