# encoding: utf-8
class Paper < ActiveRecord::Base

  belongs_to :category
  
  default_scope :order => "papers.created_at desc"

  
end
