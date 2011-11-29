# encoding: utf-8
class UserMailer < ActionMailer::Base
  default :from => "robot@gankao.co"

  def notice_manage(user,category_name,password)
    @user=user
    @category_name=category_name
    @password=password
    mail(:to => user.email, :subject =>"注意，你成为#{category_name}科目管理员" )
  end
end
