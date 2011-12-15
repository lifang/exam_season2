#encoding: utf-8
class WordQuestionRelation < ActiveRecord::Base
  belongs_to :word
  belongs_to :question
end
