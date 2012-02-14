# encoding: utf-8
class LicensesController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :access?
  def index
    @invite_codes = InviteCode.search(nil, params[:page])
  end

  def search
    @invite_codes = InviteCode.search(params[:code].strip, params[:page])
    render "index"
  end

  def code_details
    sql="select id,name,created_at from vicegerents v where 1=1"
    sql += " and v.name like '%#{params[:info]}%'" if params[:info]!="" and !params[:info].nil?
    @vices =Vicegerent.find_by_sql(sql)
    @detail={}
    @vices.each do |vice|
      codes=InviteCode.find_by_sql("select bu.num number,ic.id,ic.is_used from invite_codes ic inner join buses bu on bu.id=ic.bus_id where ic.vicegerent_id=#{vice.id} and ic.status=#{InviteCode::STATUS[:NOMAL]}")
      num=codes.blank? ? 0 : codes.size
      no=codes.blank? ?  "未关联" : codes[0].number
      no_used=0
      used=0
      codes.each do |code|
        no_used +=1 if !code.is_used
        used +=1  if code.is_used
      end unless codes.blank?
      @detail[vice.id]=[vice.name,no,num,vice.created_at,"#{used}/#{no_used}"]
    end unless @vices.blank?
    respond_with do |format|
      format.js
    end
  end


end
