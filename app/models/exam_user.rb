# encoding: utf-8
class ExamUser < ActiveRecord::Base
  belongs_to :user
  #has_many :rater_user_relations,:dependent=>:destroy
  belongs_to :examination
  #has_many :exam_raters,:through=>:rater_user_relations,:foreign_key=>"exam_rater_id"
  belongs_to :paper
  require 'rexml/document'
  include REXML
  require 'spreadsheet'

  IS_SUBMITED = {:YES => 1, :NO => 0} #用户是否提交 1 提交 2 未提交
  IS_USER_AFFIREMED = {:YES => 1, :NO => 0} #用户是否确认  1 已确认 0 未确认
  default_scope :order => "exam_users.total_score desc"
  
  #查找特定场考试的考卷
  def self.get_paper(examination)
    exam_users=ExamUser.find_by_sql("select e.id exam_user_id, r.id relation_id,e.total_score,
        r.is_marked, e.is_submited from exam_users e inner join orders o on o.user_id = e.user_id
        left join rater_user_relations r on r.exam_user_id= e.id
        where e.examination_id=#{examination} and e.answer_sheet_url is not null")
    return exam_users
  end

  def self.score_users(examination)
    exam_user=ExamUser.find_by_sql("select u.name,u.email,eu.total_score,r.id relation_id, 
      r.is_marked, o.id order_id, eu.is_submited from exam_users eu inner join users u on u.id=eu.user_id
      left join orders o on o.user_id = eu.user_id
      left join rater_user_relations r on r.exam_user_id=eu.id
      where eu.examination_id=#{examination} and eu.answer_sheet_url is not null")
    return exam_user
  end

  #自动统计考试的分数
  def self.generate_user_score(answer_doc, paper_doc)
    auto_score = 0.0
    paper_doc.root.elements["blocks"].each_element do |block|
      block_score = 0.0
      old_block_score = 0.0
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          if question.attributes["correct_type"].to_i != Problem::QUESTION_TYPE[:CHARACTER] &&
              question.attributes["correct_type"].to_i != Problem::QUESTION_TYPE[:SINGLE_CALK]
            unless answer_doc.root.elements["paper/questions"].nil?
              q_answer = answer_doc.root.elements["paper/questions"].elements["question[@id='#{question.attributes["id"]}']"]
              unless q_answer.nil? or q_answer.elements["answer"].nil?
                old_block_score += q_answer.attributes["score"].to_f
                score = 0.0
                if q_answer.elements["answer"].text != nil and q_answer.elements["answer"].text != "" and
                    question.elements["answer"] != nil and question.elements["answer"].text != nil
                  answers = []
                  question.elements["answer"].text.split(";|;").collect { |item| answers << item.strip }
                  if answers.length == 1
                    score = (answers[0].strip == q_answer.elements["answer"].text.strip) ? question.attributes["score"].to_f : 0.0
                  else
                    q_answers = []
                    q_answer.elements["answer"].text.split(";|;").collect { |item| q_answers << item.strip }
                    all_answer = answers | q_answers
                    if all_answer == answers
                      if answers - q_answers == []
                        score = question.attributes["score"].to_f
                      elsif q_answers.length < answers.length
                        score = (question.attributes["score"].to_f)/2
                      end
                    elsif all_answer.length > answers.length
                      score = 0.0
                    end
                  end
                end
                q_answer.add_attribute("score", "#{score}")
                block_score += score
                auto_score += score
              end
            end
          end
        end unless problem.elements["questions"].nil?
      end
      unless answer_doc.root.elements["paper/blocks"].nil?
        block_xml = answer_doc.root.elements["paper/blocks"].elements["block[@id='#{block.attributes["id"]}']"]
        block_xml.add_attribute("score", 
          "#{block_xml.attributes["score"].to_f - old_block_score + block_score}") unless block_xml.nil?
      end
    end
    answer_doc.root.elements["paper"].elements["auto_score"].text = auto_score
    rate_score = answer_doc.root.elements["paper"].elements["rate_score"]
    total_score = auto_score
    unless rate_score.text.nil? or rate_score.text == ""
      total_score += answer_doc.root.elements["paper"].elements["rate_score"].text.to_f
    end
    answer_doc.root.elements["paper"].add_attribute("score", "#{total_score.round}")
    puts "generate_user_score success"
    return answer_doc
  end

  #自动批卷完成
  def set_auto_rater(total_score=nil)
    self.total_score = total_score
#    self.toggle!(:is_auto_rate)
    self.save
  end

  #显示答卷
  def self.show_result(paper_id, doc)
    @xml = ExamRater.open_file("#{Constant::PAPER_PATH}/#{paper_id}.xml")
    @xml.elements["blocks"].each_element do  |block|
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          doc.elements["paper"].elements["questions"].each_element do |element|
            if element.attributes["id"]==question.attributes["id"]
              question.add_attribute("user_answer","#{element.elements["answer"].text}")
              question.add_attribute("user_score","#{element.attributes["score"]}")
            end
          end
        end
      end
    end
    return @xml
  end

  #筛选题目
  def self.answer_questions(xml, doc)
    str = "-1"
    xml.elements["blocks"].each_element do  |block|
      block.elements["problems"].each_element do |problem|
        if (problem.attributes["types"].to_i !=Problem::QUESTION_TYPE[:CHARACTER] and
              problem.attributes["types"].to_i !=Problem::QUESTION_TYPE[:COLLIGATION])
          block.delete_element(problem.xpath)
        else
          score = 0
          problem.elements["questions"].each_element do |question|
            doc.elements["paper"].elements["questions"].each_element do |element|
              if element.attributes["id"]==question.attributes["id"]
                question.add_attribute("user_answer","#{element.elements["answer"].text}")
                score += element.attributes["score"].to_i
                question.add_attribute("score_reason","#{element.attributes["reason"]}")
                question.add_attribute("user_score","#{element.attributes["score"]}")
              end
            end
            if question.attributes["correct_type"].to_i ==Problem::QUESTION_TYPE[:CHARACTER]
              str += (","+question.attributes["id"])
            else
              problem.delete_element(question.xpath)
            end
          end
          problem.add_attribute("user_score","#{score}")
        end
        block.delete_element(problem.xpath) if problem.elements["questions"].elements[1].nil?
      end
    end
    xml.add_attribute("ids","#{str}")
    return xml
  end

end
