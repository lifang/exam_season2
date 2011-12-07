# encoding: utf-8
class PlanTask < ActiveRecord::Base
  belongs_to :study_plan
  TASK_TYPES = {:PRACTICE => 0, :EXAM => 1, :RECITE => 2}  #0 真题  1 考试  2 背单词
  PERIOD_TYPES = {:EVERYDAY => 0, :PERIOD => 1} #0 每天  1 周期
end
