#encoding: utf-8
require 'rubygems'
require 'google_chart'
require 'net/https'
require 'uri'
require 'open-uri'
namespace :operate do
  desc "operate charts"
  task(:charts => :environment) do
    x_axis_labels = []
    xy_axis_labels =[]
    max_x = 0
    xy_axis = {}
    statistics = Statistic.find_by_sql("select * from statistics where TO_DAYS(NOW())-TO_DAYS(created_at)<=30 and TO_DAYS(NOW())-TO_DAYS(created_at)>=1")
    start_month = 0
    statistics.each do |data|
      start_month = data.created_at.month unless data.created_at.month == start_month
      x_label = (data.created_at.strftime("%Y%m%d").to_s)[4, 8]
      x_axis_labels << x_label
      xy_axis["0_#{x_label.to_i}"] = data.register_num
      xy_axis["1_#{x_label.to_i}"] = data.action_num
      xy_axis["2_#{x_label.to_i}"] = data.pay_num
      xy_axis["3_#{x_label.to_i}"] = data.money_num
      max_x = x_label.to_i if x_label.to_i > max_x
    end
    x_axis = x_axis_labels.sort
    step =  (x_axis_labels.length-1 > 0) ? max_x/(x_axis_labels.length-1) : max_x
    x_labels = []
    (0..3).each do |i|
      num=[]
      x_axis.each_with_index do |item, index|
        x_labels << "#{item[0, 2]}/#{item[2, 3]}" unless  x_labels.include?("#{item[0, 2]}/#{item[2, 3]}")
        num << [index * step, xy_axis["#{i}_#{item.to_i}"]]
      end
      xy_axis_labels[i]=num
    end
    (0..3).each do |index|
      lc = GoogleChart::LineChart.new('700x100', "", true)
      lc.data "charts", xy_axis_labels[index], '458B00'
      big_data=[]
      xy_axis_labels[index].each do |number|
        big_data << number[1]
      end
      num=big_data.max
      n=(num/100.0 +0.5).floor
      if  n==(num/100.0).floor && n*100<num
        data=((n+0.5)*100).to_i
      else
        data=(n*100).to_i
      end
      labels=[]
      (0..5).each do |i|
        step=data/5
        labels << i*step
      end
      lc.max_value [max_x,data]
      lc.axis :x, :labels => x_labels
      lc.axis :y, :labels => labels
      lc.data_encoding = :text
      lc.show_legend = false
      write_img(URI.escape(lc.to_url({:chm => "o,0066FF,0,-1,6"})),index)
    end
    puts "Chart success generated"
  end

  def write_img(url,index)  #上传图片
    all_dir = ""
    file_name ="#{Time.now.strftime("%Y%m%d").to_s}_#{index}.jpg"
    all_dir = "#{File.expand_path(Rails.root)}/public/charts/#{Time.now.strftime("%Y%m%d").to_s}/"
    unless File.directory?(all_dir)
      Dir.mkdir(all_dir)
    end
    file_url="#{all_dir}#{file_name}"
    open(url) do |fin|
      File.open(file_url, "wb+") do |fout|
        while buf = fin.read(1024) do
          fout.write buf
        end
      end
    end
    image_url="/charts/#{Time.now.strftime("%Y%m%d").to_s}/#{file_name}"
    Chart.create(:created_at=>Time.now.strftime("%Y-%m-%d").to_s,:types=>index,:image_url=>image_url) unless Chart.find(:first,:conditions =>"created_at='#{Time.now.strftime("%Y-%m-%d")}' and image_url='#{image_url}'") if File.exists?(file_url)
      puts "Chart #{index} success generated"
  end

end

