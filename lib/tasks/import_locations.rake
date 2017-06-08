namespace :import do
  task :locations => :environment do

    puts 'start'
    Location.delete_all
    File.open('public/地区码_20170531.csv', 'r') do |file|
		  csv = CSV.new(file, headers: true, encoding: 'utf-8')
      while row_hash = csv.shift
        bbo = Location.new
        bbo.chinese_sort_name = row_hash['中文简称']
        bbo.location_code = row_hash['地区码']
        bbo.location_name = row_hash['区域名称']
        bbo.pub_location_code = row_hash['上级区域编码']
        bbo.save
      end
    end
    puts 'end'
  end
end

