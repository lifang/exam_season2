# encoding: utf-8
class Paper < ActiveRecord::Base
  require 'rexml/document'
  include REXML

  belongs_to :category
  has_many :examination_paper_relations,:dependent=>:destroy
  has_many :examinations, :through=>:examination_paper_realations, :source => :examination
  belongs_to :user,:foreign_key=>"creater_id"
  
  default_scope :order => "papers.created_at desc"

  # 未审核、已审核、所有 
  CHECKED = {:NO => 0, :YES => 1, :ALL => 2}

  STATUS={0=>"未审核",1=>"已审核"}

  # 试卷筛选 + 分页    通过paper_js_url 是否为空 判断是否通过审核
  def Paper.search_method(category_id,checked, per_page, page)
    sql = "select * from papers where types != #{Examination::TYPES[:SPECIAL]} and category_id = #{category_id}"
    sql += " and (status = #{CHECKED[:NO]} or status is null) " if checked==CHECKED[:NO]
    sql += " and status = #{CHECKED[:YES]}" if checked==CHECKED[:YES]
    sql += " order by created_at desc"
    return Paper.paginate_by_sql(sql, :per_page =>per_page, :page => page)
  end

  #创建试卷的文件
  def create_paper_url(str, path, file_type, super_path = "paper_xml")
    file_name = self.write_file(str, path, file_type, super_path)
    if file_type == "xml"
      self.paper_url = "/"+super_path + file_name
    else
      self.paper_js_url = "/"+super_path + file_name
    end
    self.save
  end

  #写文件
  def write_file(str, path, file_type, super_path)
    dir = "#{Rails.root}/public/#{super_path}"
    Dir.mkdir(dir) unless File.directory?(dir)
    unless File.directory?(dir + "/" + path)
      Dir.mkdir(dir + "/" + path)
    end
    file_name = "/" + path + "/#{self.id}." + file_type
    url = dir + file_name
    f=File.new(url,"w+")
    f.write("#{str.force_encoding('UTF-8')}")
    f.close
    return file_name
  end

  #创建xml文件
  def xml_content(options = {})
    content = "<?xml version='1.0' encoding='UTF-8'?>"
    content += <<-XML
      <paper id='#{self.id}' total_num='0' total_score='0' time='#{self.time}'>
        <base_info>
          <title>#{self.title.force_encoding('ASCII-8BIT')}</title>
          <category>#{self.category_id}</category>
          <creater>#{self.creater_id}</creater>
          <created_at>#{self.created_at.strftime("%Y-%m-%d %H:%M").force_encoding('ASCII-8BIT')}</created_at>
          <updated_at>#{self.updated_at.strftime("%Y-%m-%d %H:%M").force_encoding('ASCII-8BIT')}</updated_at>
          <description></description>
    XML
    options.each do |key, value|
      content+="<#{key}>#{value.force_encoding('ASCII-8BIT')}</#{key}>"
    end unless options.empty?
    content += <<-XML
      </base_info>
      <blocks>
        <block id='' time='' total_num='4' total_score='106.5'>
            <base_info>
                <title>Part I	Writing</title>
                <description></description>
            </base_info>
            <problems></problems>
            </block>
      </blocks>
       <problem_ids></problem_ids>
      </paper>
    XML
    return content
  end

  #置试卷的使用状态
  def set_paper_used!
    self.toggle!(:is_used)
  end

  #打开试卷
  def open_file
    file=File.open "#{Constant::PUBLIC_PATH}#{self.paper_url}"
    doc = Document.new(file)
    file.close
    return doc
  end

  #生成试卷的json
  def create_paper_js(doc)
    doc.root.elements["blocks"].each_element do |block|
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          doc.delete_element("#{question.xpath}/answer") if question.elements["answer"]
          doc.delete_element("#{question.xpath}/analysis") if question.elements["analysis"]
        end unless problem.elements["questions"].nil?
      end unless block.elements["problems"].nil?
    end
    return "papers = " + Hash.from_xml(doc.to_s).to_json
  end


  #生成试卷的答案
  def create_paper_answer_js(doc)
    paper_element = doc.root.clone
    new_problems = paper_element.add_element("problems")
    doc.root.elements["blocks"].each_element do |block|
      block.elements["problems"].each_element do |problem|
        new_problem = new_problems.add_element("problem")
        problem.elements["questions"].each_element do |question|
          unless question.nil?
            q_element = question.clone
            answer = Element.new("answer")
            answer.text = question.elements["answer"].text if question.elements["answer"]
            q_element.add_element(answer)
            analysis = Element.new("analysis")
            analysis.text = question.elements["analysis"].text if question.elements["analysis"]
            q_element.add_element(analysis)
            new_problem.add_element(q_element)
          end
        end unless problem.elements["questions"].nil?
      end unless block.elements["problems"].nil?
    end
    return "answer = " + Hash.from_xml(paper_element.to_s).to_json
  end

  
end
