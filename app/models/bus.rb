#encoding: utf-8
class Bus < ActiveRecord::Base
  has_many :invite_codes
end
