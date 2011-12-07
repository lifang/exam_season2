# encoding: utf-8
class PlanTask < ActiveRecord::Base
  belongs_to :study_plan
  TYPES = {:EXERCISE => 0, :READ=> 1, :SIMULATION => 2}
  PERIOD_TYPES={:EVERY_DAY=>0,:TOTAL_PERIOD=>1}
end
