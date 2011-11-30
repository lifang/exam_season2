# encoding: utf-8
module ApplicationHelper

  def deny_access
    redirect_to "/"
  end

  def signed_in?
    return cookies[:user_id] != nil
  end


 
end
