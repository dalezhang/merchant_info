
namespace :mass_meachant do
  task :do => :environment do

    puts 'start'
    u = User.find '5950d424c8b1ea0e3e58064d'
    merchants = u.merchants.where(status: 1).order('created_at asc').take(200)
    ids = []
    merchants.each do |obj|
    	if !obj.request_and_response.pfb_request.present?
		    abc(obj)
		    sleep(10)
    	end

	end
	def abc(obj)
		pfb_biz = Biz::PfbMctInfo.new obj
	    puts "prepare_request: #{obj.id}"
	    pfb_biz.prepare_request
	    bz = Biz::PfbInfcApi.new(obj.id, 'wechat_offline')
		result = bz.send_intfc('新增')
	    bz = Biz::PfbInfcApi.new(obj.id, 'alipay')
		result = bz.send_intfc('变更')
		obj.update(status: 5)
	rescue Exception => e
		puts "fail at #{obj.id}"
	end
	merchants1 = u.merchants.where(status: 5)
	merchants1.each do |obj|

		    bz = Biz::PfbInfcApi.new(obj.id, 'wechat_offline')
    		result = bz.send_intfc('变更')
		    bz = Biz::PfbInfcApi.new(obj.id, 'alipay')
    		result = bz.send_intfc('变更')
    		puts obj.id



	end

    puts 'end'
  end
end

