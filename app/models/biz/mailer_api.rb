class Biz::MailerApi
	def initialize(title)
		@title = title
	end
	def send(email_address,txt)
		url = Rails.application.secrets.pooul['mail_host']
		js = {
		email: email_address,
		from: Rails.application.secrets.pooul['service_email_address'],
		subject: @title,
		body: txt
		}
		binding.pry
		response = HTTParty.post(url, body: js.to_json)
		if response['code'] != 0
			raise response.to_json
		end
	end
end