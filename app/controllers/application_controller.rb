# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include UserRoleHelper
  include RemotePaginateHelper
  include Constant

  def access?
    deny_access unless signed_in?
  end

  def proof_code(len)
    #    chars = ('A'..'Z').to_a + ('a'..'z').to_a
    chars = (1..9).to_a
    code_array = []
    1.upto(len) {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end

  


end
