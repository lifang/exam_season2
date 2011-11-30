class PapersController < ApplicationController

  before_filter :access?
  
  #[get][collection] 试卷列表
  def index
    category=params["category"]
    checked=params["checked"].to_i unless params["checked"].nil?
    @papers=Paper.search_mothod(category,checked,5, params[:page])
  end

  
end
