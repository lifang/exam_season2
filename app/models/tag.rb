# encoding: utf-8
class Tag < ActiveRecord::Base
  has_many :problem_tag_relations,:dependent=>:destroy
  has_many :problems,:through=>:problem_tag_relations,:foreign_key=>"problem_id"
  has_many :question_tag_relations,:dependent=>:destroy
  has_many :questions,:through=>:question_tag_relations,:foreign_key=>"question_id"

  #判断标签是否存在
  def Tag.is_exists?(*name)
    tags = Tag.find_all_by_name(*name)
    return tags.any?
  end


  #创建标签
  def Tag.create_tag(name)
    new_tags = []
    real_name = {}
    existed_name = []
    name.each { |na| real_name[na] = na }
    tags = Tag.find_all_by_name(real_name.values)
    tags.collect do |t|
      new_tags << t
      existed_name << t.name
    end
    (name - existed_name).each do  |n|
      new_tags << Tag.create(:name => n, :num => (Tag.tag_num)[-1])
    end unless (name - existed_name).blank?
    return new_tags
  end

  #为tag生成有序数列 2 4 8 16 32...
  def self.create_tag_num
    tag_num = 2
    max_num = Tag.maximum("num")
    puts max_num
    tag_num = max_num * 2 if !max_num.nil? and max_num > 0
    return tag_num
  end

  #生成素数标识每个标签
  def self.tag_num
    tag_num = Tag.maximum("num")
    arr = [2]
    if tag_num.nil? or tag_num == 0
      start_num = 2
    else
      start_num = tag_num
      end_num = (start_num.to_s.length + 1) * 100
      3.step(end_num, 2) do |n|
        if Tag.is_prime?(arr, n)
          arr << n
          break if n > start_num
        end
      end      
    end
    return arr
  end


  def self.is_prime?(arr, number)
    j=0
    while arr[j] * arr[j] <= number
      return false if number % arr[j] ==0
      j +=1
    end
    return true
  end

end
