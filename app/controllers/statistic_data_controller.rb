# encoding: utf-8
class StatisticDataController < ApplicationController

  def index
    @register=StatisticData.register_num
    @action=StatisticData.action_num
    web_buyer=StatisticData.web_buyer_num
    competes_buyer=StatisticData.competes_buyer_num
    @buyers_30=web_buyer["0"][0].ids+competes_buyer["0"][0].ids
    @fee_30=web_buyer["0"][0].ids*36+competes_buyer["0"][0].ids*10
    @buyers_all=web_buyer["1"][0].ids+competes_buyer["1"][0].ids
    @fee_all=web_buyer["1"][0].ids*36+competes_buyer["1"][0].ids*10
  end

  def user_30
    url=Constant::PUBLIC_PATH +Constant::DIR_ROOT
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    file_name=url+"/#{Time.now.to_data.to_s}_user.xls"
    unless File.exist?(file_name)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{姓名 邮箱}
      exam_users = ExamUser.find_by_sql("select name,email from users")
      exam_users.each_with_index do |exam_user, index|
        sheet.row(index+1).concat ["#{exam_user.name}", "#{exam_user.email}"]
      end
      book.write url      
    end
    render :inline => "<script>window.location.href='#{Constant::UNAFFIRM_PATH}#{file_name}';</script>"
  end

  def user_all

  end

  

end
