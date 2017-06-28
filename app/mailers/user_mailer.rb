class UserMailer < ActionMailer::Base

  default from: "dale@pooul.cn", reply_to: "dale@pooul.cn"

  layout 'mailer'

  def reset_password_instructions(email)
    @user = User.find_by(email: email)
    mail(to: email, subject: '普尔云进件系统')
  end

end
