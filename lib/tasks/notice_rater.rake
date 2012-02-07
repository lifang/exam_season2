# encoding: utf-8

namespace :notice_rater do
  desc "notice rater"
  task(:email => :environment) do
    
    sql_str ="select count(e.id) sum,e.examination_id from exam_users e inner join orders o on o.user_id = e.user_id
        inner join examinations ex on ex.id=e.examination_id
        left join rater_user_relations r on r.exam_user_id= e.id
        where e.is_submited=1 and r.is_marked is null and ex.types=#{Examination::TYPES[:SIMULATION]} group by e.examination_id"
    info1 = ExamUser.find_by_sql(sql_str)
    exam_array=[]  #记录已经发送邮件的考试，避免重复发送
    unless info1.blank?
      puts "is_marked = null"
      info1.each do |info|
        @examination=Examination.find(info.examination_id)
        puts info.examination_id
        exam_array<<info.examination_id
        @examination.exam_raters.each do |exam_rater|
          UserMailer.notice_rater(exam_rater,@examination).deliver
        end unless @examination.exam_raters.blank?
      end
    end

    sql_str ="select count(e.id) sum,e.examination_id, r.exam_rater_id from exam_users e inner join orders o on o.user_id = e.user_id
        inner join examinations ex on ex.id=e.examination_id
        left join rater_user_relations r on r.exam_user_id= e.id
        where e.is_submited=1 and r.is_marked=#{RaterUserRelation::MARK[:NO]} and ex.types=#{Examination::TYPES[:SIMULATION]} group by e.examination_id,r.exam_rater_id"
    info2 = ExamUser.find_by_sql(sql_str)
    unless info2.blank?
      puts "is_marked=0"
      info2.each do |info|
        unless exam_array.include?(info.examination_id)
          puts info.examination_id
          @examination=Examination.find(info.examination_id)
          @examination.exam_raters.each do |exam_rater|
            UserMailer.notice_rater(exam_rater,@examination).deliver
          end unless @examination.exam_raters.blank?
        end
      end
    end
  end
end

