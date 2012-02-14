# encoding: utf-8
class VicegerentsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :access?

  def index
  @vices=Vicegerent.paginate_by_sql("select * from vicegerents order by created_at desc",:per_page=>1,:page=>params[:page])
  end
 
end
