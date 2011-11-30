# encoding: utf-8
class UsersController < ApplicationController
  def index
    @action_count = User.paginate_by_sql(["select u.id user_id, u.username, u.email,
        al.total_num, al.last_update_time, al.week_num from users u
        left join user_action_logs al on al.user_id = u.id"],
      :per_page => 10, :page => params[:page])
  end

  def show
    @user = User.find(params[:id].to_i)
    @user_action_logs = UserActionLog.find_by_user_id(params[:id].to_i)
    @user_actions = ActionLog.paginate_by_sql(["select * from action_logs a
      where a.user_id = ? order by a.created_at desc", params[:id].to_i], :per_page => 10, :page => params[:page])
  end






















end
