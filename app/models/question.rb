# encoding: utf-8
class Question < ActiveRecord::Base
  belongs_to :problem
  has_many :question_tag_relations,:dependent=>:destroy
  has_many :tags,:through=>:question_tag_relations,:foreign_key=>"tag_id"
  has_many :word_question_relations,:dependent=>:destroy
  has_many :words,:through=>:word_question_relations, :source => :word


CORRECT_TYPE = {:SINGLE_CHOSE => 0, :MORE_CHOSE => 1, :JUDGE => 2, :SINGLE_CALK => 3,
    :COLLIGATION => 4, :CHARACTER => 5, :MORE_BLANKS => 6 }
  #0 单选题； 1 多选题；2 判断题；3 填空题； 4 综合题； 5 简答题； 6 完型填空

end