# encoding: utf-8
class LicensesController < ApplicationController
  before_filter :access?
  require 'spreadsheet'
  require 'fileUtils'
  
  def index
    @invite_codes = InviteCode.search(nil, params[:page])
  end

  def search
    @invite_codes = InviteCode.search(params[:code].strip, params[:page])
    render "index"
  end

  def search_vicegerent
    unless params[:vicegerent].strip.empty?
      @vicegerents = Vicegerent.find(:all, :conditions => [" name like ?", "%#{params[:vicegerent].strip}%"])
    else
      @vicegerents = Vicegerent.all
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def generate
    bus_code = Bus.generate_bus
    chars = ('A'..'Z').to_a + ('a'..'z').to_a + ('1'..'9').to_a
    code_array = []    
    (0..params[:num].to_i*2).each do |i|
      arr = []
      1.upto(8) {arr << chars[rand(chars.length)]}
      code_array << arr.join
    end
    root_url=Constant::PUBLIC_PATH + InviteCode::CODE_EXCEL_PATH
    unless File.directory?(root_url)
      Dir.mkdir(root_url)
    end
    file_url = "/#{bus_code}.xls"
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet.row(0).concat %w{批次号 授权码 代理人 到期时间}
    begin
      vicegerent = Vicegerent.find(params[:v_id].to_i)
      bus = Bus.create(:num => bus_code)
      (code_array.uniq)[0, params[:num].to_i].each_with_index do |code, index|
        InviteCode.create(:code => bus_code + code, :vicegerent_id => params[:v_id], :bus_id => bus.id,
          :status => 0, :ended_at => params[:ended_at])
        sheet.row(index+1).concat ["#{bus_code}", "#{bus_code}#{code}", "#{vicegerent.name}", "#{params[:ended_at]}"]
      end
      sheet.row(params[:num].to_i + 2).concat ["总计", "#{params[:num].to_i}"]
      book.write root_url + file_url
      flash[:pic_warn] = "授权码生成成功，<a style='color:red;' href='#{InviteCode::CODE_EXCEL_PATH}#{file_url}'>下载授权码</a>"
#      render :inline => "<script>window.location.href='#{InviteCode::CODE_EXCEL_PATH}#{file_url}';</script>"
    rescue
      flash[:notice] = "授权码生成失败，请重新尝试生成"      
    end
    redirect_to request.referer
  end

end
