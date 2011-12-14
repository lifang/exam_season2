# encoding: utf-8
class ProblemTagRelation < ActiveRecord::Base
  belongs_to:problem
  belongs_to:tag
end



