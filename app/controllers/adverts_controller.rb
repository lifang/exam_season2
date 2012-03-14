# encoding: utf-8
class AdvertsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :access?

  def index
    session[:advert_text] = nil
    @adverts=Advert.paginate_by_sql("select r.id,a.created_at,a.content,r.name,r.parent_id,a.id a_id,re.name r_name from adverts a inner join regions r on r.id=a.region_id inner join regions re on re.id=r.parent_id order by a.created_at desc",:per_page=>8,:page=>params[:page])
    @provines=Region.all(:conditions=>"parent_id=0")
  end


  def list_city
    sql="select name,id from regions where parent_id=#{params[:region_id]}"
    @city=Region.find_by_sql(sql)
    respond_with(@city) do |format|
      format.js
    end
  end

  def advert_create
    region_id=params[:city]
    unless params[:advert_id].nil? || params[:advert_id]==""
      Advert.find(params[:advert_id].to_i).update_attributes(:content=>params[:text_content],:region_id=>region_id)
    else
      params[:text_content].split("||").each do |content|
        Advert.create(:content=>content,:region_id=>region_id)
      end
    end
    redirect_to  "/adverts"
  end

  def advert_search
    session[:advert_region] = nil
    session[:advert_region] = params[:search_region] unless params[:search_region]=="" or params[:search_region].length==0
    session[:search_city]=nil
    session[:search_city] = params[:search_city] unless params[:search_city]=="" or params[:search_city].length==0
    redirect_to advert_list_adverts_path
  end

  def advert_list
    sql="select r.id,a.created_at,a.content,r.name,r.parent_id,a.id a_id,re.name r_name from adverts a inner join regions r on r.id=a.region_id inner join regions re on re.id=r.parent_id where 1=1"
    sql += " and re.id=#{session[:advert_region]}" unless session[:advert_region].nil?
    sql += " and a.region_id=#{session[:search_city]}" unless session[:search_city].nil?
    sql +="  order by a.created_at desc"
    @adverts=Advert.paginate_by_sql(sql,:per_page=>8,:page=>params[:page])
    @provines=Region.all(:conditions=>"parent_id=0")
    render "index"
  end

  def search_city
    sql="select name,id from regions where parent_id=#{params[:region_id]}"
    @city=Region.find_by_sql(sql)
    respond_with(@city) do |format|
      format.js
    end
  end
end