class UserMailer < ActionMailer::Base
  default from: "<Email>"     # Change Accordingly
  
  def welcome_email(name, email, password)
    @name = name
    @email = email
    @pass = password
    @url = '172.18.3.197:3000/tests/home'
    mail(to: @email, subject: "Welcome #{@name}")
  end
  
  def reset_pass_email(name, email, password)
    @name = name
    @email = email
    @pass = password
    @url = '172.18.3.197:3000/tests/home'
    mail(to: @email, subject: "Welcome #{@name}")
  end
  
end