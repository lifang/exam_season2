#encoding: utf-8
class ExaminationTagRelation < ActiveRecord::Base
  belongs_to :examination
  belongs_to :tag

  #新建专题的xml文档
  def self.create_document(category_id)
    return Document.new("<category id='#{category_id}'></category>")
  end

  #写专题xml文档
  def self.create_all_elements(doc, tags, paper_urls)
    tags.each do |t|
      puts "tag #{t.name}'s special paper start"
      e = Element.new("block")
      e.add_attribute("tag_id", t.id)  #创建tag相关的block
      e.add_attribute("tag_name", t.name)
      paper_urls.each do |paper_url|
        paper_doc = self.open_file(Rails.root + "/public" + paper_url)
        e = self.create_tag(e, paper_doc, t.name)
      end
      doc.add_child(e)
      puts "tag #{t.name}'s special paper end"
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
        problem.elements["questions"].each_element do |question|
          unless question.elements["tags"].text=~ /#{tag.strip}/
            if paper_doc.elements["problems/#{problem.attributes["id"]}"]
              special_problem = paper_doc.elements["problems/#{problem.attributes["id"]}"]
            else
              special_problem = problem.clone
              special_doc.add_child(special_problem.delete_element("/questions").add_element("questions"))
            end
            special_problem.add_child(question)
          end unless question.nil?
        end unless problem.elements["questions"].nil?
      end unless block.elements["problems"].nil?
    end
    return special_doc
  end

  def self.write_xml(doc)
    doc.each_element do |block|
      exist_examination = Examination.find_by_sql(["select p.id
        from examination_tag_relations etr
        inner join examinations e on e.id = etr.examination_id
        inner join examination_paper_relations epr on epr.examination_id = e.id
        inner papers p on p.id = epr.paper_id
        inner join tags t on t.id = etr.tag_id where e.types = ? and e.status = ?
        and e.category_id = ? and etr.tag_id = ? limit 1",
          Examination::TYPES[:SPECIAL], Examination::STATUS[:GOING],
          doc.attributes["id"].to_i.to_i, block.attributes["tag_id"].to_i])
      Paper.transaction do
        if exist_examination.blank?
          paper = Paper.create(:creater_id=>ADMIN_ID, :title=>"#{block.attributes["tag_name"]}专项练习题",
            :category_id => doc.attributes["id"].to_i, :types => Examination::TYPES[:SPECIAL])
          examination = Examination.create!(:title => paper.title, :creater_id => ADMIN_ID,
            :is_published => true, :status => Examination::STATUS[:GOING],
            :category_id => doc.attributes["id"].to_i, :types => Examination::TYPES[:SPECIAL])
          examination.update_paper("create", [paper])
          ExaminationTagRelation.create(:tag_id => block.attributes["tag_id"].to_i, :examination_id => examination.id)
        else
          paper = Paper.find(exist_examination.id)
        end
        last_document = Document.new(paper.xml_content).elements["blocks"].add_child(block)
        paper.create_paper_url(last_document.to_s, "paper_xml/#{Time.now.strftime("%Y%m%d")}", "xml")
        paper.create_paper_url(paper.create_paper_js, "paperjs/#{Time.now.strftime("%Y%m%d")}", "js")
      end
    end unless doc.nil?
  end
end
