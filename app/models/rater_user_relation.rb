
# encoding: utf-8
class RaterUserRelation < ActiveRecord::Base
  belongs_to :exam_rater
  belongs_to :exam_user

  #是否已经打分完成
  MARK = {:NO => 0, :YES => 1}
end
