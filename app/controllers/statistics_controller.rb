# encoding: utf-8
class StatisticsController < ApplicationController
  require 'spreadsheet'

  def index
    @count_num=Statistic.find(:first, :order => "created_at desc")
    charts=Chart.find_by_sql("select max(created_at), image_url, types from charts group by types")
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
      sheet.row(0).concat %w{姓名 邮箱}
      users =User.find_by_sql("select name,email,code_type from users #{file_name[1]}")
      users.each_with_index do |user, index|
        sheet.row(index+1).concat ["#{user.name}", "#{user.email}"]
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
    file_name=Statistic.download_expr(params[:action_types],"action","1+1")
    file_url=url+file_name[0]
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{姓名 邮箱 动作对象 所属科目 动作类型 动作次数}
      actions =ActionLog.find_by_sql("select u.name u_name,u.email,al.types,al.remark,ca.name ca_name,total_num from action_logs al
                           inner join users u on u.id=al.user_id inner join categories ca on ca.id=al.category_id #{file_name[1]}")
      actions.each_with_index do |action, index|
        sheet.row(index+1).concat ["#{action.u_name}", "#{action.email}","#{action.remark}","#{action.ca_name}","#{ActionLog::TYPE_NAMES[action.types]}","#{action.total_num}"]
      end
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
        sheet.row(0).concat %w{购买类型 购买人数}
        buyers =Order.find_by_sql("select count(*) ids,ca.name from orders o inner join categories ca on ca.id=o.category_id #{file_name[1]}
                                   group by category_id")
        total_num=0
        buyers.each_with_index do |buyer, index|
          total_num +=buyer.ids
          sheet.row(index+1).concat ["#{buyer.name}","#{buyer.ids}"]
        end
        next_line=buyers.size+1
        fees=Compete.find_by_sql("select count(*) ids from competes #{file_name[1]}")
        sheet.row(next_line+1).concat ["模考统计", "#{fees[0].ids}"]
        sheet.row(next_line+3).concat ["人数总计","#{total_num+fees[0].ids}"]
      elsif types==5 || types==6|| types==7|| types==8
        sheet.row(0).concat %w{fee_types total_price}
        buyers =Order.find_by_sql("select sum(o.total_price) total_prices,ca.name from orders o inner join categories ca on
                                   ca.id=o.category_id #{file_name[1]} group by category_id")
        num=0
        buyers.each_with_index do |buyer, index|
          sheet.row(index+1).concat ["#{buyer.name}","#{buyer.total_prices}"]
          num +=buyer.total_prices
        end
        sheet.row(buyers.size+1).concat ["小计", "#{num}"]
        next_line=buyers.size+1
        fees=Compete.find_by_sql("select sum(price) prices from competes #{file_name[1]}")
        sheet.row(next_line+2).concat ["模考统计", "#{fees[0].prices}"]
        sheet.row(next_line+3).concat ["总计", "#{num+fees[0].prices}"] unless fees[0].prices.nil?
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
      sheet.row(0).concat %w{姓名 邮箱 动作对象 所属科目 动作类型 动作次数}
      actions =ActionLog.find_by_sql("select u.name u_name,u.email,al.types,al.remark,ca.name ca_name ,total_num from action_logs al
                               inner join users u on u.id=al.user_id inner join categories ca on ca.id=al.category_id #{file_name[1]}")
      actions.each_with_index do |action, index|
        sheet.row(index+1).concat ["#{action.u_name}", "#{action.email}","#{action.remark}","#{action.ca_name}","#{ActionLog::TYPE_NAMES[action.types]}","#{action.total_num}"]
      end
      sheet.row(actions.size+1).concat ["总计", "#{actions.size}"]
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{Time.now.strftime("%Y%m%d").to_s+file_name[0]}';</script>"

  end
end
