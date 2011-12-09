# encoding: utf-8
class Question < ActiveRecord::Base
  belongs_to :problem
  has_many :question_tag_relations,:dependent=>:destroy
  has_many :tags,:through=>:question_tag_relations,:foreign_key=>"tag_id"
  has_many :feedbacks

  #创建题点
  def Question.create_question(problem, options = {}, attr_array = [])
    options[:problem_id] = problem.id
    options[:question_attrs] = attr_array.join(";-;") if attr_array.any?
    Question.create(options)
  end

  #更新提点
  def Question.update_question(question_id, options = {}, attr_array = [])
    question = Question.find(question_id)
    options[:question_attrs] = attr_array.join(";-;") if attr_array.any?
    question.update_attributes(options) unless options.empty?
    return question
  end

  #创建题点标签
  def question_tags(tags)
    self.tags = []
    tags.each { |tag| self.tags << tag }
  end

  #综合题的提点信息整理
  def self.colligation_questions(question_str)
    all_question = []
    if question_str != ""
      questions = question_str.split("||")
      questions.each do |question|
        if question != ""
          question_hash = {}
          key_values = question.gsub("{", "").gsub("}", "").split(",|,")
          key_values.each do |key_value|
            attrs = key_value.split("=>")
            question_hash[attrs[0]] = attrs[1]
          end
          question_attr = []
          unless (question_hash["attr_value"].nil? or question_hash["attr_value"] == "")
            question_attr = question_hash["attr_value"].split(";|;")
          end
          question_hash["question_attr"] = question_attr
          all_question << question_hash
        end
      end
    end
    return all_question
  end

  #更新综合题的所有提点信息,update_flag有两个值，如果是create，则表示是新增，如果是update，则表示是更新
  def self.update_colligation_questions(problem, questions, update_flag)
    score_arr = {}
    questions.each do |question_hash|
      if update_flag == "create"
        question = Question.create_question(problem,
          {:answer => question_hash["answer"], :analysis => question_hash["analysis"],
            :correct_type => question_hash["correct_type"].to_i, :description => question_hash["diescription"]},
          question_hash["question_attr"])
      else
        question = Question.update_question(question_hash["question_id"].to_i,
          {:answer => question_hash["answer"], :analysis => question_hash["analysis"],
            :description => question_hash["diescription"]}, question_hash["question_attr"])
      end
      #创建标签
      if !question_hash["tag"].nil? and question_hash["tag"] != ""
        tag_name = question_hash["tag"].split(" ")
        question.question_tags(Tag.create_tag(tag_name))
      end
      score_arr[question.id] = question_hash["score"].to_i
    end
    return score_arr
  end


  #专家模式组装简答题提点
  def self.generate_question_hash(question = {}, right_split, left_split, content)
    right_contents = content.split(right_split)
    length = (right_contents.length%2 == 0) ? right_contents.length-2 : right_contents.length-1
    (0..length).each do |i|
      left_contents = right_contents[i].split(left_split)
      if right_split == "}}"
        question[question.length] = [Problem::QUESTION_TYPE[:CHARACTER],
          left_contents[1]] unless (left_contents[1].nil? or left_contents[1] == "")
      else
        question[question.length] = [-1, left_contents[1]] unless (left_contents[1].nil? or left_contents[1] == "")
      end
    end unless right_contents.blank?
    return question
  end


  #专家模式-根据已有的提点hash组装成可持久化的提点
  def self.generate_question_for_database(question_hash)
    questions = []
    question_hash.values.each do |v|
      hash_tmp = {}
      tags = v[1].split("||")
      hash_tmp[:tag] = tags[1] unless tags[1].nil?
      answers = tags[0].split("|")
      question_attr = []
      if answers.length == 1 #表示当前提点为填空或简答题
        hash_tmp[:correct_type] = (v[0] != -1) ? v[0] : Problem::QUESTION_TYPE[:SINGLE_CALK]
        hash_tmp[:correct_type] =
          Problem::QUESTION_TYPE[:JUDGE] if (answers[0].strip == "no" or answers[0].strip == "yes")
      else       
        hash_tmp[:correct_type] = answers[0].split(";").length == 1 ?
          Problem::QUESTION_TYPE[:SINGLE_CHOSE] : Problem::QUESTION_TYPE[:MORE_CHOSE]
        (0..answers.length-1).each do |i|
          question_attr += answers[i].split(";") unless answers[i] == ""
        end
      end
      hash_tmp[:answer] = answers[0].gsub(";", ";|;")
      hash_tmp[:question_attr] = question_attr
      questions << hash_tmp
    end
    return questions
  end

  #专家模式统计分数或解析，分数以“[()]”区分，解析以“[{}]”区分
  #一道题可以有多个分值或解析，多个分值/解析之间用“,|”隔开
  def self.generate_score_or_analysis(content, right_split, left_split)
    score_or_analysis = []
    content_right = content.split(right_split)
    length = (content_right.length%2 == 0) ? content_right.length-2 : content_right.length-1
    (0..length).each do |i|
      scores_or_analysises = content_right[i].split(left_split)
      scores_or_analysises[1].split(",|").each do |single|
        score_or_analysis << single unless single.nil?
      end unless scores_or_analysises[1].nil?
    end
    return score_or_analysis
  end



end
