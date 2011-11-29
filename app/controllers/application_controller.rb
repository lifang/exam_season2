# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  def proof_code(len)
    #    chars = ('A'..'Z').to_a + ('a'..'z').to_a
    chars = (1..9).to_a
    code_array = []
    1.upto(len) {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end

  include ApplicationHelper
  include UserRoleHelper
  
end
