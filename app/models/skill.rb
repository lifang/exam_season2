# encoding: utf-8
class Skill < ActiveRecord::Base
  belongs_to :user
  require 'rexml/document'
  include REXML

  #TYPES = {:LINSTEN => 1, :WORD => 2, :READ => 3, :SPEAK => 4} #听力  单词  阅读  口语
  CET_SKILL_NAME = {0 => "听力", 1 => "词汇", 2 => "阅读", 3 => "写作", 4 => "其它"}
  GRADUATE_SKILL_NAME = {0 => "翻译", 1 => "词汇", 2 => "阅读", 3 => "写作", 4 => "其它"}

  PASS = { :NOT => 0, :YES =>1 }

  #创建xml文件
  def self.xml_content(total_text)
    content = "<?xml version='1.0' encoding='UTF-8'?><skill>"
    total_text.split("((sign))").each do |con|
      content += "<next>#{con}</next>"
    end
    content +="</skill>"
    return content
  end


  #写文件
  def self.write_xml(url,str_con)
    f=File.new("#{Constant::FRONT_PUBLIC_PATH+url}","w+")
    doc=Document.new(f).root
    doc=(xml_content(str_con).force_encoding('UTF-8'))
    f.write(doc)
    f.close
  end

  def self.open_xml(url)
    dir = "#{Constant::FRONT_PUBLIC_PATH}"
    file=File.open(dir+url)
    doc=Document.new(file)
    file.close
    return doc
  end
  
end
