# encoding: utf-8
class NoticesController < ApplicationController
  def index
    @notices = Notice.paginate_by_sql(["select n.*, u.username, c.name c_name from notices n
          left join users u on u.id = n.send_id left join categories c on c.id = n.category_id 
          where send_types = ? order by n.created_at desc ",
        Notice::SEND_TYPE[:SYSTEM]],
      :per_page => 10, :page => params[:page])
  end

  def create
    Notice.create(:started_at => params[:started_at], :ended_at => params[:ended_at],
      :send_types => Notice::SEND_TYPE[:SYSTEM], :send_id => cookies[:user_id].to_i,
      :category_id => params[:category_id], :description => params[:description])
    redirect_to notices_path
  end

  def single_notice
    Notice.create(:send_types => Notice::SEND_TYPE[:SINGLE], :send_id => cookies[:user_id].to_i,
      :target_id => params[:user_id].to_i, :description => params[:description])
    respond_to do |format|
      format.js
    end
  end
  
end
