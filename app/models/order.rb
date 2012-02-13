# encoding: utf-8
class Order< ActiveRecord::Base
  belongs_to :user
  STATUS = {:NOMAL => 1, :INVALIDATION => 0} #1 正常  0 失效
  TYPES = {:CHARGE => 1, :OTHER => 0,:TRIAL_SEVEN => 2, :ACCREDIT => 3,:COMPETE => 4} #1 付费  0 其它 2 七天试用
  TYPE_NAME = {1 => "付费", 0 => "其它",2=>"七天试用",3=>"授权码",4=>"模考大赛"}
end
