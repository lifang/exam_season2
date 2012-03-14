# encoding: utf-8
class VicegerentsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :access?

  def index
    session[:vice_text] = nil
    @vices=Vicegerent.paginate_by_sql("select * from vicegerents order by created_at desc",:per_page=>10,:page=>params[:page])
  end

  def vice_search
    session[:vice_text] = nil
    session[:vice_text] = params[:vice_name]
    redirect_to vice_list_vicegerents_path
  end

  def vice_list
    @vices = Vicegerent.paginate_by_sql("select * from vicegerents where name like '%#{session[:vice_text] }%' order by created_at desc",:per_page=>10,:page=>params[:page])
    render "index"
  end

  def vice_create
    vice=Vicegerent.first(:conditions=>"name='#{params[:name].strip}'")
    if vice.nil?
      Vicegerent.create(:name => params[:name].strip, :phone => params[:phone].strip,
        :inline => params[:connect].strip, :address => params[:address].strip)
      flash[:notice]="代理人创建成功"
    else
      flash[:notice]="代理人已存在"
    end
    redirect_to request.referer
  end


  def vice_update
    Vicegerent.find(params[:update_id].to_i).update_attributes(:name => params[:name].strip, :phone => params[:phone].strip,
      :inline => params[:connect].strip, :address => params[:address].strip)
    flash[:notice]="更新成功"
    redirect_to request.referer
  end
 

end
