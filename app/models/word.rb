#encoding: utf-8
class Word < ActiveRecord::Base
  belongs_to :category
#  has_many :word_sentences
#  has_many :word_discriminate_relations,:dependent => :destroy
#  has_many :discriminates,:through=>:word_discriminate_relations, :source => :discriminate

  TYPES = {"n." => 0, "v." => 1, "pron." => 2, "adj." => 3, "adv." => 4,
    "num." => 5, "art." => 6, "prep." => 7, "conj." => 8, "interj." => 9, "u = " => 10, "c = " => 11, "pl = " => 12}
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
