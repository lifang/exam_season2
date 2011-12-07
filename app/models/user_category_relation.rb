# encoding: utf-8
class UserCategoryRelation < ActiveRecord::Base
  belongs_to:user
  belongs_to:category

  TYPES = {:NOMAL => 0, :CHARGE => 1, :PROBATION => 2} #0 普通  1 收费  2 免费试用
  TYPE_NAME = {0 => "普通", 1 => "收费", 2 => "免费试用"}
  STATUS = {:NOMAL => 1, :INVALIDATION => 0} #0 失效 1 正常
end
