# encoding: utf-8
namespace :user do
  task(:action_logs => :environment) do
    puts "user_action_logs start"
    all_type_action = ActionLog.find_by_sql(["select sum(al.total_num) total_count,
      ifnull(sum(case when al.types=0 then al.total_num end), 0) log_count,
      ifnull(sum(case when al.types=1 then al.total_num end), 0) practice_count,
      ifnull(sum(case when al.types=2 then al.total_num end), 0) exam_count,
      ifnull(sum(case when al.types=3 then al.total_num end), 0) recite_count,
      ifnull(sum(case when al.types=4 then al.total_num end), 0) study_play_count,
      max(al.created_at) max_time,
      floor((unix_timestamp(max(al.created_at))-unix_timestamp(min(al.created_at)))/(60*60*24*7) + 1) week_time,
      al.user_id
      from action_logs al group by al.user_id"])
    all_type_action.each do |action|
      user_action_log = UserActionLog.find_by_user_id(action.user_id)
      if user_action_log.nil?
        UserActionLog.create(:user_id => action.user_id,
        :total_num => "#{action.total_count.to_i},#{action.log_count.to_i},#{action.practice_count.to_i},#{action.exam_count.to_i},#{action.recite_count.to_i},#{action.study_play_count.to_i}",
        :last_update_time => action.max_time, :week_num => action.week_time)
      else
        user_action_log.update_attributes(:last_update_time => action.max_time, :week_num => action.week_time,
          :total_num => "#{action.total_count.to_i},#{action.log_count.to_i},#{action.practice_count.to_i},#{action.exam_count.to_i},#{action.recite_count.to_i},#{action.study_play_count.to_i}")
      end
    end unless all_type_action.blank?
    puts all_type_action.length.to_s + " update"
  end
end