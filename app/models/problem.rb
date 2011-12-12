# encoding: utf-8
class Problem < ActiveRecord::Base
  has_one:problem_tag
  belongs_to:category
  has_many:problem_tag_relations,:dependent=>:destroy
  has_many :tags,:through=>:problem_tag_relations,:foreign_key=>"tag_id"
  has_many:questions,:dependent=>:destroy

  require 'rexml/document'
  include REXML

  #小题类型 题面外：0  题面内：1
  QUESTION_TYPE = {:OUTER=>0,:INNER=>1}


  
  #  #创建problem
  #  def Problem.create_problem(paper, options = {})
  #    options[:category_id] = paper.category_id
  #    return Problem.create(options)
  #  end
  #
  #  #打开xml
  #  def self.open_xml(url)
  #    return Document.new(url)
  #  end
  #
  #  #将新的内容写进xml
  #  def self.write_xml(url, doc)
  #    file = File.new(url, File::CREAT|File::TRUNC|File::RDWR, 0644)
  #    file.write(doc)
  #    file.close
  #  end
  #
  #  #创建问题的xml
  #  def create_problem_xml(doc, block_id, remove_problem,options = {})
  #    #添加问题的xml
  #    block = doc.root.elements["blocks"].elements["block[@id='#{block_id}']"]
  #    problems = block.elements["problems"]
  #    problem = problems.add_element("problem")
  #    problem.add_attribute("id","#{self.id}")
  #    problem.add_attribute("types", "#{self.types}")
  #    title = problem.add_element("title")
  #    title.add_text("#{self.title}")
  #    problem.add_element("category").add_text("#{self.category_id}")
  #    problem.add_element("complete_title").add_text("#{self.complete_title}") unless self.complete_title.nil?
  #    if remove_problem!=nil
  #      problem.parent.insert_after(remove_problem,problem)
  #    end
  #    #添加题点xml
  #    questions = problem.add_element("questions")
  #    self.update_question_xml(questions, options)
  #    #更新题目、试卷模块和试卷的分数
  #    problem_score = self.generate_problem_score(options)
  #    problem.add_attribute("score","#{problem_score}")
  #    block.attributes["total_score"] = (block.attributes["total_score"].to_f + problem_score.to_f).round(2)      #更新模块总分
  #    doc.root.attributes["total_score"] = (doc.root.attributes["total_score"].to_f + problem_score.to_f).round(2)     #更新试卷总分
  #    #更新试卷模块、试卷题目数
  #    block.attributes["total_num"] = block.attributes["total_num"].to_i + questions.size                #更新模块总题数
  #    doc.root.attributes["total_num"] = doc.root.attributes["total_num"].to_i + questions.size          #更新试卷总题数
  #    doc.root.elements["base_info"].elements["updated_at"].text=Time.now.strftime("%Y-%m-%d %H:%M")      #试卷更新时间
  #
  #    return doc
  #  end
  #
  #  #指定题目位置
  #  def change_position(doc, problem, position)
  #    problem.parent.insert_before(doc.elements["#{problem.parent.xpath}/problem[#{position}]"],problem)
  #    return doc
  #  end
  #
  #  def change_colligation_position(doc,question,position)
  #    question.parent.insert_before(doc.elements["#{question.parent.xpath}/question[#{position}]"],question)
  #    return doc
  #  end
  #
  #
  #  #删除试题
  #  def self.remove_problem_xml(doc, problem_path)
  #    problem = doc.elements["#{problem_path}"]
  #    unless problem.nil?
  #      block = problem.parent.parent
  #      #更新块和试卷的总分
  #      question_num = 0
  #      problem.elements['questions'].each_element {|q| question_num += 1 }
  #      doc.root.attributes["total_num"] = doc.root.attributes["total_num"].to_i - question_num
  #      block.attributes["total_num"] = block.attributes["total_num"].to_i - question_num
  #      block.attributes["total_score"] = (block.attributes["total_score"].to_f - problem.attributes["score"].to_f).round(2)
  #      doc.root.attributes["total_score"] = (doc.root.attributes["total_score"].to_f - problem.attributes["score"].to_f).round(2)
  #      doc.delete_element(problem_path)
  #    end
  #    return doc
  #  end
  #
  #  #根据提点的分值计算题目的总分
  #  def generate_problem_score(options = {})
  #    problem_score = 0.0
  #    options[:score].values.each do |value|
  #      problem_score += value.to_f
  #    end if !options.empty? and !options[:score].nil?
  #    return problem_score
  #  end
  #
  #  #更新题目的题点内容
  #  def update_question_xml(questions, options = {})
  #    self.questions.each do |q|
  #      question = questions.add_element("question")
  #      question.add_attribute("id","#{q.id}")
  #      question.add_attribute("correct_type", "#{q.correct_type}")
  #      question.add_element("description").add_text("#{q.description}") unless q.description.nil?
  #      question.add_element("answer").add_text("#{q.answer}") unless q.answer.nil?
  #      question.add_element("analysis").add_text("#{q.analysis}") unless q.analysis.nil?
  #      question_attrs = question.add_element("questionattrs")
  #      question_attrs.add_text("#{q.question_attrs}") unless q.question_attrs.nil?
  #      tags = question.add_element("tags")
  #      tag_names = []
  #      q.tags.collect { |tag| tag_names << tag.name  }
  #      tags.add_text("#{tag_names.join(' ')}") unless q.tags.blank?
  #      question.add_attribute("score", options[:score][q.id]) if !options.empty? and !options[:score].nil?
  #    end
  #  end
  #
  #  #更新题目的标签
  #  def update_problem_tags
  #    self.tags = []
  #    tags_hash = {}
  #    self.questions.each do |question|
  #      question.tags.each do |tag|
  #        tags_hash[tag.id] = tag
  #      end
  #    end
  #    self.tags << tags_hash.values
  #    self.update_search_table
  #  end
  #
  #  #更新标签查询表
  #  def update_search_table
  #    total_num = 1
  #    self.tags.each do |t|
  #      total_num = total_num * t.num
  #    end
  #    problem_tag = ProblemTag.find_or_create_by_problem_id(self.id)
  #    problem_tag.total_num = total_num
  #    problem_tag.save
  #  end
  #
  #  #计算修改题目原来每个题点的成绩
  #  def old_score(score_arr, doc, problem_path)
  #    old_score = {}
  #    problem = doc.elements["#{problem_path}"]
  #    problem.elements["questions"].each_element do |que|
  #      old_score[que.attributes["id"].to_i] = que.attributes["score"].to_f
  #    end
  #    return old_score.merge(score_arr)
  #  end
  #
  #  def Problem.search_mothod(start_at, end_at, category, type, tags, per_page, page)
  #    sql = "select p.*,pt.total_num from problems p left join problem_tags pt on p.id=pt.problem_id where 1=1"
  #    sql += " and created_at > '#{start_at}'" unless start_at.nil?||start_at==""
  #    sql += " and created_at < '#{end_at}'" unless end_at.nil?||end_at==""
  #    sql += " and category_id = #{category}" unless category.nil?||category==""
  #    sql += " and types = #{type}" unless type.nil?||type==""
  #    sql += " and pt.total_num%#{Problem.search_tags(tags.to_s)} = 0 "
  #    sql += " order by updated_at desc"
  #    return Problem.paginate_by_sql(sql, :per_page =>per_page, :page => page)
  #  end
  #
  #  def self.search_tags(tag)
  #    tag_num = 1
  #    unless tag.nil? or tag == ""
  #      tags = tag.split(" ")
  #      in_condition = tags.to_s.gsub("[","").gsub("]","")
  #      all_tags = Tag.where("name in (#{in_condition})")
  #      all_tags.collect { |t| tag_num = tag_num * t.num  }
  #    end
  #    return tag_num
  #  end
  #
  #  def Problem.search_items_num(tag,category,type,ids)
  #    sql = "select count(p.id) item_num,r.total_num from problems p left join problem_tags r on p.id=r.problem_id where 1=1"
  #    sql += " and category_id = #{category}" unless category.nil?||category==""
  #    sql += " and types = #{type}" unless type.nil?||type==""
  #    sql += " and r.total_num%#{search_tags(tag)} = 0 "
  #    sql += " and p.id not in (#{ids})" unless ids.nil?
  #    if  sql == "select count(p.id) item_num,r.total_num from problems p left join problem_tags r on p.id=r.problem_id where 1=1"
  #      return []
  #    else
  #      return Problem.find_by_sql(sql)
  #    end
  #  end
  #
  #
  #  def Problem.search_items(tag,category,type,num,ids)
  #    sql = "select p.* from problems p left join problem_tags r on p.id=r.problem_id  where 1=1"
  #    sql += " and category_id = #{category}" unless category.nil?||category==""
  #    sql += " and types = #{type}" unless type.nil?||type==""
  #    sql += " and r.total_num%#{search_tags(tag)} = 0 "
  #    sql += " and p.id not in (#{ids})" unless ids.nil?
  #    if  sql == "select p.* from problems p left join problem_tags r on p.id=r.problem_id  where 1=1"
  #      return []
  #    else
  #      sql += " order by rand() limit #{num}"
  #      return Problem.find_by_sql(sql)
  #    end
  #  end

end



