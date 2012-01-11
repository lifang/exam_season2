# encoding: utf-8
require 'rexml/document'
include REXML
namespace :paper do
  desc "rate paper"
  task(:rate => :environment) do
    #自动批卷
    exam_users = ExamUser.find_by_sql("select e.id, e.user_id,
        e.total_score, e.paper_id, p.paper_url, e.answer_sheet_url, e.is_auto_rate, rur.is_authed, exm.is_should_rate
        from exam_users e inner join papers p on p.id = e.paper_id
        left join rater_user_relations rur on rur.exam_user_id = e.id
        inner join examinations exm on exm.id = e.examination_id
        where e.is_submited = 1 and e.answer_sheet_url is not null 
        and e.is_auto_rate = 0 and exm.types = #{Examination::TYPES[:SIMULATION]} ")
    puts exam_users.size
    dir = Constant::FRONT_PUBLIC_PATH
    paper_dir = "#{Rails.root}/public"
    exam_users.each do |exam_user|
      #if exam_user.is_should_rate == 0 or
      #    (exam_user.is_should_rate == 1 and !exam_user.is_authed.nil? and exam_user.is_authed != 0)
      puts exam_user.is_should_rate
      p_file = File.open(paper_dir + exam_user.paper_url)
      a_file = File.open(dir + exam_user.answer_sheet_url)
      paper_xml = Document.new(p_file)
      answer_xml = Document.new(a_file)
      p_file.close
      a_file.close
      answer_xml = ExamUser.generate_user_score(answer_xml, paper_xml)
      f = File.new(dir + exam_user.answer_sheet_url,"w+")
      f.write("#{answer_xml.to_s.force_encoding('UTF-8')}")
      f.close
      eu = ExamUser.find(exam_user.id)
      total_score = answer_xml.root.elements["paper"].attributes["score"].nil? ? 0
      : answer_xml.root.elements["paper"].attributes["score"].to_f.round
      eu.set_auto_rater(total_score)
      puts exam_user.id.to_s + " rate success"
      Collection.auto_add_collection(answer_xml, paper_xml, exam_user.user_id)
      puts exam_user.id.to_s + " collection success"
      #end
    end unless exam_users.blank?
    #统计排名
    exam_user_count = ExamUser.find_by_sql("select count(e.id) user_count, e.examination_id examination_id
        from exam_users e inner join orders o on o.user_id = e.user_id
        inner join examinations exm on exm.id = e.examination_id
        where e.is_submited = 1 and e.total_score is not null
        and exm.types = #{Examination::TYPES[:SIMULATION]} group by e.examination_id")
    exam_user_count.each do |e|
      if e.user_count >= 1000
        puts e.examination_id.to_s + "prepare"
        exam_records = ExamUser.find_by_sql("select e.*
            from exam_users e inner join orders o on o.user_id = e.user_id
            where e.total_score is not null and e.examination_id = #{e.examination_id} ")
        score_hash = []
        exam_records.each do |record|
          score_hash << record.total_score
        end unless exam_records.blank?
        sort_arr = score_hash.length > 0 ? score_hash.sort : []    #排序好的所有的成绩
        exam_records.each do |record|
          position = sort_arr.index(record.total_score)
          record.rank = BigDecimal("#{(position + 1)*100.to_f/e.user_count}").ceil(2) unless position == -1
          record.save
        end unless exam_records.blank?
      else
        puts e.examination_id.to_s + " not enough"
      end
    end unless exam_user_count.blank?
  end
end

