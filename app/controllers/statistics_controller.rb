# encoding: utf-8
class StatisticsController < ApplicationController
  require 'spreadsheet'

  def index
    @count_num=Statistic.find(:first, :order => "created_at desc")
    charts=Chart.find_by_sql("select  max(image_url) image_url, types from charts group by types")
    @chart_url={}
    charts.collect {|chart| @chart_url[chart.types]=chart.image_url }
  end

  def user_info
    root_url=Constant::PUBLIC_PATH + Constant::DIR_ROOT
    url=root_url+"/#{Time.now.strftime("%Y%m%d").to_s}"
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    file_name=Statistic.user_expr(params[:action_types])
    file_url=url+file_name[0]
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{编号 姓名 邮箱}
      users =User.find_by_sql("select id,name,email,code_type from users #{file_name[1]}")
      users.each_with_index do |user, index|
        sheet.row(index+1).concat ["#{user.id}","#{user.name}", "#{user.email}"]
      end
      sheet.row(users.size+1).concat ["总计", "#{users.size}"]
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{Time.now.strftime("%Y%m%d").to_s+file_name[0]}';</script>"
  end


  def action_info
    root_url=Constant::PUBLIC_PATH + Constant::DIR_ROOT
    url=root_url+"/#{Time.now.strftime("%Y%m%d").to_s}"
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    file_name=Statistic.download_expr(params[:action_types],"action","1=1")
    file_url=url+file_name[0]
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{编号 姓名 邮箱 动作对象 所属科目 动作类型 动作次数}
      actions =ActionLog.find_by_sql("select u.id u_id,u.name u_name,u.email,al.types,al.remark,ca.name ca_name,total_num from action_logs al
                           inner join users u on u.id=al.user_id left join categories ca on ca.id=al.category_id #{file_name[1]}")
      actions.each_with_index do |action, index|
        sheet.row(index+1).concat ["#{action.u_id}","#{action.u_name}", "#{action.email}","#{action.remark}","#{action.ca_name}","#{ActionLog::TYPE_NAMES[action.types]}","#{action.total_num}"]
      end unless actions.blank?
      sheet.row(actions.size+1).concat ["总计", "#{actions.size}"]
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{Time.now.strftime("%Y%m%d").to_s+file_name[0]}';</script>"

  end



  def buyer_info
    root_url=Constant::PUBLIC_PATH + Constant::DIR_ROOT
    url=root_url+"/#{Time.now.strftime("%Y%m%d").to_s}"
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    types=params[:action_types].to_i
    file_name=Statistic.download_info(types)
    file_url=url+file_name[0]
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      if types==1 || types==2 || types==3 || types==4
        sheet.row(0).concat %w{编号 购买科目 购买类型 用户名称 用户邮箱}
        buyers =Order.find_by_sql("select u.id,o.category_id, ca.name, u.name u_name, u.email, o.types from orders o
                                   inner join users u on u.id = o.user_id
                                   left join categories ca on ca.id=o.category_id
                                   #{file_name[1]} and o.types = #{Order::TYPES[:CHARGE]} 
                                   order by o.category_id desc ")
        buyers.each_with_index do |buyer, index|
          buyer_name = buyer.category_id.nil? ? "模考收费" : buyer.name
          sheet.row(index+1).concat ["#{buyer.id}","#{buyer_name}", "#{Order::TYPE_NAME[buyer.types]}", "#{buyer.u_name}", "#{buyer.email}"]
        end unless buyers.blank?
        next_line=buyers.size+2
        sheet.row(next_line).concat ["人数总计","#{buyers.size}"]
      elsif types==5 || types==6|| types==7|| types==8
        sheet.row(0).concat %w{编号 购买科目 购买类型 价格 用户名称  用户邮箱}
        buyers =Order.find_by_sql("select u.id,o.category_id, ifnull(o.total_price, 0) total_prices, ca.name, u.name u_name, u.email, o.types
                                   from orders o inner join users u on u.id = o.user_id
                                   left join categories ca on ca.id=o.category_id
                                   #{file_name[1]} and o.types = #{Order::TYPES[:CHARGE]} 
                                   order by o.category_id desc ")
        num=0
        buyers.each_with_index do |buyer, index|
          buyer_name = buyer.category_id.nil? ? "模考收费" : buyer.name
          sheet.row(index+1).concat ["#{buyer.id}","#{buyer_name}", "#{Order::TYPE_NAME[buyer.types]}", "#{buyer.total_prices}", "#{buyer.u_name}", "#{buyer.email}"]
          num += buyer.total_prices
        end
        sheet.row(buyers.size+2).concat ["总计", "#{num}"]
      end
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{Time.now.strftime("%Y%m%d").to_s+file_name[0]}';</script>"
  end

  def login_info
    root_url=Constant::PUBLIC_PATH + Constant::DIR_ROOT
    url=root_url+"/#{Time.now.strftime("%Y%m%d").to_s}"
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    file_name=Statistic.download_expr(params[:action_types],"login","types=0")
    file_url=url+file_name[0]
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{编号 姓名 邮箱 动作对象 所属科目 动作类型 动作次数}
      actions =ActionLog.find_by_sql("select u.id,u.name u_name,u.email,al.types,al.remark,ca.name ca_name ,total_num from action_logs al
                               inner join users u on u.id=al.user_id left join categories ca on ca.id=al.category_id #{file_name[1]}")
      actions.each_with_index do |action, index|
        sheet.row(index+1).concat ["#{action.id}","#{action.u_name}", "#{action.email}","#{action.remark}","#{action.ca_name}","#{ActionLog::TYPE_NAMES[action.types]}","#{action.total_num}"]
      end unless actions.blank?
      sheet.row(actions.size+1).concat ["总计", "#{actions.size}"]
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{Time.now.strftime("%Y%m%d").to_s+file_name[0]}';</script>"

  end
end
