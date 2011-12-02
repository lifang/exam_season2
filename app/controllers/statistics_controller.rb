# encoding: utf-8
class StatisticsController < ApplicationController
  require 'spreadsheet'

  def index
    @count_num=Statistic.count_num
    charts=Chart.find_by_sql("select max(created_at), image_url,types from charts group by types")
    @chart_url={}
    charts.each do |chart|
      @chart_url[chart.types]=chart.image_url
    end
  end

  def user_info
    url=Constant::PUBLIC_PATH + Constant::DIR_ROOT
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    if params[:action_types].to_i==1
      file_name="/#{Time.now.to_date.to_s}_user_30.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    else
      file_name="/#{Time.now.to_date.to_s}_user_all.xls"
    end
    file_url=url+file_name
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{姓名 邮箱}
      users =User.find_by_sql("select name,email from users #{expression}")
      users.each_with_index do |user, index|
        sheet.row(index+1).concat ["#{user.name}", "#{user.email}"]
      end
      sheet.row(users.size+1).concat ["总计", "#{users.size}"]
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{file_name}';</script>"
  end


  def action_info
    url=Constant::PUBLIC_PATH + Constant::DIR_ROOT
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    if params[:action_types].to_i==1
      file_name="/#{Time.now.to_date.to_s}_action_30.xls"
      expression=" where TO_DAYS(NOW())-TO_DAYS(al.created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(al.created_at)>=1"
    else
      file_name="/#{Time.now.to_date.to_s}_action_all.xls"
    end
    file_url=url+file_name
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).concat %w{姓名 邮箱 动作对象 所属科目 动作类型}
      actions =ActionLog.find_by_sql("select u.name u_name,u.email,al.types,al.remark,ca.name ca_name from action_logs al inner join users u on u.id=al.user_id inner join categories ca on ca.id=al.category_id #{expression}")
      actions.each_with_index do |action, index|
        sheet.row(index+1).concat ["#{action.u_name}", "#{action.email}","#{action.remark}","#{action.ca_name}","#{action.types}"]
      end
      sheet.row(actions.size+1).concat ["总计", "#{actions.size}"]
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{file_name}';</script>"

  end



  def buyer_info
    url=Constant::PUBLIC_PATH + Constant::DIR_ROOT
    unless File.directory?(url)               #判断dir目录是否存在，不存在则创建 下3行
      Dir.mkdir(url)
    end
    if params[:action_types].to_i==1
      file_name="/#{Time.now.to_date.to_s}_buyer_30.xls"
      order_expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
      competes_expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    elsif params[:action_types].to_i==2
      file_name="/#{Time.now.to_date.to_s}_buyer_all.xls"
    elsif params[:action_types].to_i==3
      file_name="/#{Time.now.to_date.to_s}_fee_30.xls"
      order_expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
      competes_expr=" where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1"
    else
      file_name="/#{Time.now.to_date.to_s}_fee_all.xls"
    end
    file_url=url+file_name
    unless File.exist?(file_url)
      Spreadsheet.client_encoding = "UTF-8"
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      if params[:action_types].to_i==1 ||params[:action_types].to_i==2
        sheet.row(0).concat %w{购买类型 购买人数}
        buyers =ActionLog.find_by_sql("select count(*) ids,ca.name from orders o inner join categories ca on ca.id=o.category_id #{order_expr} group by category_id")
        total_num=0
        buyers.each_with_index do |buyer, index|
          total_num +=buyer.ids
          sheet.row(index+1).concat ["#{buyer.name}","#{buyer.ids}"]
        end
        next_line=buyers.size+1
        fees=ActionLog.find_by_sql("select count(*) ids from competes #{competes_expr}")
        sheet.row(next_line+1).concat ["模考统计", "#{fees[0].ids}"]
        sheet.row(next_line+3).concat ["人数总计","#{total_num+fees[0].ids}"]
      elsif params[:action_types].to_i==3 ||params[:action_types].to_i==4
        sheet.row(0).concat %w{fee_types total_price}
        buyers =ActionLog.find_by_sql("select sum(o.total_price) total_prices,ca.name from orders o inner join categories ca on ca.id=o.category_id #{order_expr} group by category_id")
        num=0
        buyers.each_with_index do |buyer, index|
          sheet.row(index+1).concat ["#{buyer.name}","#{buyer.total_prices}"]
          num +=buyer.total_prices
        end
        sheet.row(buyers.size+1).concat ["小计", "#{num}"]
        next_line=buyers.size+1
        fees=ActionLog.find_by_sql("select sum(price) prices from competes #{competes_expr}")
        sheet.row(next_line+2).concat ["模考统计", "#{fees[0].prices}"]
        sheet.row(next_line+3).concat ["总计", "#{num+fees[0].prices}"]
      end
      book.write file_url
    end
    render :inline => "<script>window.location.href='/data/#{file_name}';</script>"
  end
  

end
