class PapersController < ApplicationController

  before_filter :access?
  #[get][collection] 试卷列表
  def index
    category=params["category"]
    @papers=Paper.search_mothod(category,params["checked"],5, params[:page])
  end

end
