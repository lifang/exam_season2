#encoding: utf-8
class ExaminationTagRelation < ActiveRecord::Base
  belongs_to :examination
  belongs_to :tag

  #新建专题的xml文档
  def self.create_document(category_id)
    e = Element.new("category")
    e.add_attribute("id", category_id)
    e.add_element("blocks")
    return e
  end

  #写专题xml文档
  def self.create_all_elements(doc, tags, paper_urls)
    tags.each do |t|
      puts "tag #{t.id}'s special paper start"
      e = Element.new("block")
      e.add_attribute("tag_id", t.id)  #创建tag相关的block
      e.add_attribute("tag_name", t.name)
      e.add_element("problems")
      paper_urls.each do |paper_url|
        paper_doc = ExaminationTagRelation.open_file("#{Rails.root}/public#{paper_url}")
        e = ExaminationTagRelation.create_tag(e, paper_doc, t.name)
      end
      doc.elements["blocks"].add_element(e)
      puts "tag #{t.id}'s special paper end"
    end unless tags.blank?
    return doc
  end

  #读xml
  def self.open_file(url)
    file = File.open(url)
    doc = Document.new(file).root
    file.close
    return doc
  end

  #创建tag
  def self.create_tag(special_doc, paper_doc, tag)
    paper_doc.elements["blocks"].each_element do |block|
      block.elements["problems"].each_element do |problem|
        special_problem = nil
        problem.elements["questions"].each_element do |question|
          if question.elements["tags"].text =~ /#{tag.strip}/
            if special_problem.nil?
              special_problem = problem.clone
              special_problem.add_element(problem.elements["title"])
              special_problem.add_element(problem.elements["category"])
              special_problem.add_element("questions")
            end
            special_problem.elements["questions"].add_element(question)
          end unless question.nil?
        end unless problem.elements["questions"].nil?
        unless special_problem.nil?
          special_doc.elements["problems"].add_element(special_problem)
        end
      end unless block.elements["problems"].nil?
    end
    return special_doc
  end

  def self.write_xml(doc)
    doc.elements["blocks"].each_element do |block|
      unless block.elements["problems"].to_s == "<problems/>"
        exist_examination = Examination.find_by_sql(["select p.id
        from examination_tag_relations etr
        inner join examinations e on e.id = etr.examination_id
        inner join examination_paper_relations epr on epr.examination_id = e.id
        inner join papers p on p.id = epr.paper_id
        inner join tags t on t.id = etr.tag_id where e.types = ? and e.status = ?
        and e.category_id = ? and etr.tag_id = ? limit 1",
            Examination::TYPES[:SPECIAL], Examination::STATUS[:GOING],
            doc.attributes["id"].to_i.to_i, block.attributes["tag_id"].to_i])
        Paper.transaction do
          if exist_examination.blank?
            paper = Paper.create(:creater_id=>Constant::ADMIN_ID, :title=>"#{block.attributes["tag_name"]}专项练习题",
              :category_id => doc.attributes["id"].to_i, :types => Examination::TYPES[:SPECIAL])
            examination = Examination.create!(:title => paper.title, :creater_id => Constant::ADMIN_ID,
              :is_published => true, :status => Examination::STATUS[:GOING],
              :category_id => doc.attributes["id"].to_i, :types => Examination::TYPES[:SPECIAL])
            examination.update_paper("create", [paper])
            ExaminationTagRelation.create(:tag_id => block.attributes["tag_id"].to_i, :examination_id => examination.id)
          else
            paper = Paper.find(exist_examination[0].id)
          end
          last_document = Document.new(paper.xml_content)
          last_document.root.elements["blocks"].add_element(block)
          paper.create_paper_url(last_document.to_s, "#{Time.now.strftime("%Y%m%d")}", "xml", "special_paper")
          paper.create_paper_url(paper.create_paper_js, "#{Time.now.strftime("%Y%m%d")}", "js", "special_paperjs")
        end
      end
    end unless doc.nil?
  end
end
