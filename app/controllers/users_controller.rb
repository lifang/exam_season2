# encoding: utf-8
class UsersController < ApplicationController
  def index
    session[:search_text] = nil
    sql = "select u.id user_id, u.username, u.email, u.created_at, u.code_type,
        al.total_num, al.last_update_time, al.week_num from users u
        left join user_action_logs al on al.user_id = u.id"
    if params[:time_sort].nil?
      sql += " order by u.username "
    else
      sql += " order by u.created_at "
      sql += " desc " if params[:time_sort].to_i == User::TIME_SORT[:DESC]
    end
    @users = User.paginate_by_sql(sql,
      :per_page => 10, :page => params[:page])
  end

  def search
    session[:search_text] = nil
    session[:search_text] = params[:search_text]
    redirect_to search_list_users_path
  end

  def search_list
    sql = "select u.id user_id, u.username, u.email, u.created_at, u.code_type,
        al.total_num, al.last_update_time, al.week_num from users u
        left join user_action_logs al on al.user_id = u.id where u.username like ? or u.email like ?"
    if params[:time_sort].nil?
      sql += " order by u.username "
    else
      sql += " order by u.created_at "
      sql += " desc " if params[:time_sort].to_i == User::TIME_SORT[:DESC]
    end
    @users = User.paginate_by_sql([sql, "%#{session[:search_text].strip}%", "%#{session[:search_text].strip}%"],
      :per_page => 10, :page => params[:page])
    render "index"
  end

  def show
    @user = User.find(params[:id].to_i)
    @login_log = ActionLog.find(:first,
      :conditions => ["user_id = ? and types = ?", params[:id].to_i, ActionLog::TYPES[:LOGIN]],
      :order => "updated_at desc")
    @user_action_logs = UserActionLog.find_by_user_id(params[:id].to_i)
    
    @user_actions = ActionLog.paginate_by_sql(["select * from action_logs a
      where a.user_id = ? order by a.created_at desc", params[:id].to_i], :per_page => 10, :page => params[:page])
  end






















end
