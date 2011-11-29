# encoding: utf-8
class UsersController < ApplicationController
  def index
    @action_count = User.paginate_by_sql(["select u.* from users u left join action_logs al on al.user_id = u.id"],
      :per_page => 10, :page => params[:page])
  end

  def show
    
  end
  
end
