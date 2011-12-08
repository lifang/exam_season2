# encoding: utf-8
module ApplicationHelper

  def deny_access
    redirect_to "/"
  end

  def signed_in?
    return cookies[:user_id] != nil
  end

  def current_user
    User.find_by_id(cookies[:user_id].to_i)
  end


 
end
