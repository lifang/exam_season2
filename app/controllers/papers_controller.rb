class PapersController < ApplicationController

  def index
    category=params["category"]
    @papers=Paper.where("category_id=#{category}").paginate(:per_page=>5,:page=>params[:page])
    
  end

end
