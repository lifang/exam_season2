#encoding: utf-8
require 'rexml/document'
include REXML
namespace :special do
  task(:update => :environment) do
    puts "special update start"
    tags = Tag.all
    #根据类型找到对应的试卷，根据试卷生成专项的试题
    papers = Examination.find_by_sql(["select e.category_id, p.paper_url from examinations e
        inner join examination_paper_relations epr on epr.examination_id = e.id
        inner join papers p on p.id = epr.paper_id where e.is_published = ? and status = ? and e.types = ?",
        Examination::IS_PUBLISHED[:ALREADY], Examination::STATUS[:GOING], Examination::TYPES[:OLD_EXAM]])
    puts "examination #{papers.size}"
    category_papers = {}
    category_ids = []
    papers.each do |p|
      category_ids << p.category_id
      unless category_papers[p.category_id].nil?
        category_papers[p.category_id] << p.paper_url
      else
        category_papers[p.category_id] = [p.paper_url]
      end
    end unless papers.blank?
    puts "category_ids #{category_ids.join(",")}"
    category_ids.each do |c|
      paper_urls = category_papers[c]
      unless paper_urls.nil? or paper_urls.blank?
        doc = ExaminationTagRelation.create_document(c.category_id)
        puts "category #{c}'s special paper start"
        ExaminationTagRelation.write_xml(ExaminationTagRelation.create_all_elements(doc, tags, paper_urls))
        puts "category #{c}'s special paper end"
      end
    end unless category_ids.blank?
  end
end


