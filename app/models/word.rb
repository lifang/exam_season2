#encoding: utf-8
class Word < ActiveRecord::Base
  belongs_to :category
  has_many :word_sentences
  has_many :word_discriminate_relations,:dependent => :destroy
  has_many :discriminates,:through=>:word_discriminate_relations, :source => :discriminate

  TYPES = {0 => "n.", 1 => "v.", 2 => "pron.", 3 => "adj.", 4 => "adv.",
    5 => "num.", 6 => "art.", 7 => "prep.", 8 => "conj.", 9 => "interj.", 10 => "u = ", 11 => "c = ", 12 => "pl = "}
  #英语单词词性 名词 动词 代词 形容词 副词 数词 冠词 介词 连词 感叹词 不可数名词 可数名词 复数
  
  def self.get_words(category_id, search_text, page)
    sql = "select w.id, w.name from words w where w.category_id = ? "
    sql += " and name like ? " unless search_text.nil? or search_text.strip.empty?
    sql += " order by name "
    unless search_text.nil? or search_text.strip.empty?
      words = Word.paginate_by_sql([sql, category_id, "%#{search_text.strip}%"], :per_page => 10, :page => page)
    else
      words = Word.paginate_by_sql([sql, category_id], :per_page => 10, :page => page)
    end
    return words
  end

  #上传音频文件
  def self.upload_enunciate(url, file_path)
    dir = "#{Rails.root}/public"
    filename = file_path.original_filename
    unless File.directory?(dir + url)
      Dir.mkdir(dir + url)
    end
    filename = url + filename
    File.open("#{File.expand_path(Rails.root)}/public#{filename}", "wb") do |f|
      f.write(file_path.read)
    end
    return filename
  end

end
