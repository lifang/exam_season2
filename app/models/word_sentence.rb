#encoding: utf-8
class WordSentence < ActiveRecord::Base
  belongs_to :word
  belongs_to :phone_word
end
