
namespace :new_role do
  task :generate => :environment do

    puts 'start'
	# role1 = Role.find_or_create_by(name: 'admin')
	# role1.update(chinese_name: '管理员')
	# role2 = Role.find_or_create_by(name: 'agent')
	# role2.update(chinese_name: '代理商')
	# User.all.each {|u| u.update(partner_id: u.partner_id.to_s)}
	# User.all.each do |u|
	# 	u.partner_id = 'merchant_info'
	# 	u.save
	# end
    puts 'end'
  end
end

