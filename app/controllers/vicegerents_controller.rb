# encoding: utf-8
class VicegerentsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :access?

  def index
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
      Vicegerent.create(:name=>params[:name],:phone=>params[:phone],:inline=>params[:connect],:address=>params[:address])
      message="代理人创建成功"
    else
      message="代理人已存在"
    end
    respond_to do |format|
      format.json {
        render :json=>{:message=>message}
      }
    end
  end

end
