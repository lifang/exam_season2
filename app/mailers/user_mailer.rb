# encoding: utf-8
class UserMailer < ActionMailer::Base
  default :from => "robot@gankao.co"

  def notice_manage(user,category_name,password)
    @user=user
    @category_name=category_name
    @password=password
    mail(:to => user.email, :subject =>"赶考网提醒您，你已成为“#{category_name}”的科目管理员" )
  end

  def rater_affirm(exam_rater,examination)
    @rater=exam_rater
    @examination=examination
    @url  = Constant::SERVER_PATH
    mail(:to => @rater.email, :subject => "赶考网阅卷老师确认")
    
  end
end
