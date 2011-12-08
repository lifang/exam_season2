# encoding: utf-8
class SessionsController < ApplicationController
  layout "login"
  def new
    @title="赶考-登录"
    
  end
  
  def login_from
    @user = User.find_by_email(params[:user_name])
    if  @user.nil?||!@user.has_password?(params[:user_password])
      flash[:error] = "用户名或密码错误"
      redirect_to request.referer
    else
      cookies[:user_id]={:value =>@user.id, :path => "/", :secure  => false}
      cookies[:user_name]={:value =>@user.name, :path => "/", :secure  => false}
      cookie_role(cookies[:user_id])
      if is_admin? || is_paper_creater?
        redirect_to "/categories"
      else
        cookies.delete(:user_id)
        cookies.delete(:user_name)
        cookies.delete(:user_roles)
        flash[:error] = "抱歉，你没有访问权限"
        redirect_to request.referer
      end
    end
  end

  #退出登录
  def destroy
    cookies.delete(:user_id)
    cookies.delete(:user_name)
    cookies.delete(:user_roles)
    redirect_to root_path
  end

end
