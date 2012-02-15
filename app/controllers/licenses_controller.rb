# encoding: utf-8
class LicensesController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :access?
  require 'spreadsheet'
  
  def index
    @invite_codes = InviteCode.search(nil, params[:page])
  end

  def search
    session[:invite_code] = nil
    session[:invite_code] = params[:code].strip
    redirect_to search_list_licenses_path
  end

  def search_list
    @invite_codes = InviteCode.search(session[:invite_code], params[:page])
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

  def code_details
    sql = "select count(i.id) total_count, ifnull(count(case when i.user_id is null then i.id end), 0) n_used_count,
      ifnull(count(case when i.user_id is not null then i.id end), 0) used_count, b.num, b.created_at, v.name v_name from invite_codes i
      inner join buses b on b.id = i.bus_id inner join vicegerents v on v.id = i.vicegerent_id "
    sql += " where v.name like '%#{params[:info].strip}%'" unless params[:info].nil? or params[:info].strip.empty?
    sql += " group by b.id"
    @vices = InviteCode.paginate_by_sql(sql, :per_page =>10, :page => params[:page])

#    sql="select id,name,created_at from vicegerents v where 1=1"
#    sql += " and v.name like '%#{params[:info]}%'" if params[:info]!="" and !params[:info].nil?
#    @vices =Vicegerent.paginate_by_sql(sql,:per_page =>10, :page => params[:page])
#    @detail={}
#    @vices.each do |vice|
#      codes=InviteCode.find_by_sql("select bu.num number,ic.id,ic.user_id from invite_codes ic inner join buses bu on bu.id=ic.bus_id where ic.vicegerent_id=#{vice.id} and ic.status=#{InviteCode::STATUS[:NOMAL]}")
#      num=codes.blank? ? 0 : codes.size
#      no=codes.blank? ?  "未关联" : codes[0].number
#      no_used=0
#      used=0
#      codes.each do |code|
#        if code.user_id.nil?
#          no_used +=1
#        else
#          used +=1
#        end
#      end unless codes.blank?
#      @detail[vice.id]=[vice.name,no,num,vice.created_at,"#{used}/#{no_used}"]
#    end unless @vices.blank?
    respond_with do |format|
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
          :status => InviteCode::STATUS[:NOMAL], :ended_at => params[:ended_at],
          :category_id => params[:category_id].to_i)
        sheet.row(index+1).concat ["#{bus_code}", "#{bus_code}#{code}", "#{vicegerent.name}", "#{params[:ended_at]}"]
      end
      sheet.row(params[:num].to_i + 2).concat ["总计", "#{params[:num].to_i}"]
      book.write root_url + file_url
      flash[:pic_warn] = "授权码生成成功，<a style='color:red;' href='#{InviteCode::CODE_EXCEL_PATH}#{file_url}'>下载授权码</a>"
    rescue
      flash[:notice] = "授权码生成失败，请重新尝试生成"      
    end
    redirect_to request.referer
  end

  def invalid
    invite = InviteCode.find(params[:id])
    invite.update_attributes(:status => InviteCode::STATUS[:INVALID]) if invite
    flash[:notice] = "操作成功"
    redirect_to request.referer
  end

  def uninvalid
    invite = InviteCode.find(params[:id])
    invite.update_attributes(:status => InviteCode::STATUS[:NOMAL]) if invite
    flash[:notice] = "操作成功"
    redirect_to request.referer
  end

end
