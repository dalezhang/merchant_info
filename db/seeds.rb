# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.find_by(email: 'example@mail.com')
unless user.present?
	user = User.create(email: 'example@mail.com', password: '111111', password_confirmation: '111111',partner_id: 'merchant_info')
end
role1 = Role.find_or_create_by(name: 'admin')
role1.update(chinese_name: '管理员')
role2 = Role.find_or_create_by(name: 'agent')
role2.update(chinese_name: '代理商')
user.roles << role1
