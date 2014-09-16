class TestsController < ApplicationController
  layout "users"
  def instructions
    if !(session[:test_id] || session[:user_id])
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'home', :controller=>'tests')   
    else
      session[:questions] = []
      t = Time.now
      x = Test.find(session[:test_id]).duration + 1
      if x >= 60
        h = (x / 60)
        session[:test_hour] = t.hour + h
        m = x % 60
        session[:test_min] = t.strftime("%M").to_i + m
      else      
        session[:test_hour] = t.hour
        session[:test_min] = t.strftime("%M").to_i + x
      end
      session[:test_sec] = t.strftime("%S")
    end
  end

  def test_paper
    if !(session[:test_id] || session[:user_id])
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'home', :controller=>'tests')
    else
      if session[:questions].blank?
        @count = Test.find(session[:test_id]).quescount
        @subject = Test.find(session[:test_id]).subject
        @ques = Question.where(quetype: @subject, isactive: 'Active').sample(@count)
        @ques.each{|z| session[:questions] << z.id}
      end
      @arr = Array.new
      session[:questions].each do |q|
        @arr << q
      end
      puts @arr
      @questions = Question.find( @arr )
    end
  end

  def result
    @correct = 0
    if params[:mcq]
      params[:mcq].each do |mcqk, mcqa|
        a = Array.new
        b = Array.new
        params[:mcq][mcqk].each{|x| b.push(x)}
        Question.find_by(id: mcqk).answers.split(",").each{|x| a.push(x)}
        if (b - a).empty? && (a - b).empty?
          @correct += 1
        end
      end
    end
    if params[:scq]
      params[:scq].each do |scqk, scqa|
        if Question.find_by(id: scqk).answers.to_s == scqa.to_s
          @correct += 1
        end
      end
    end
    @count = Test.find(session[:test_id]).quescount.to_i
    @incorrect = @count - @correct
    @test_time = "#{session[:test_hour]}:#{session[:test_min]}:#{session[:test_sec]}"
    if !Result.find_by(user_id: session[:user_id], test_time: @test_time)
      @result = Result.new()
      @result.test_id = session[:test_id]
      @result.user_id = session[:user_id]
      @result.correct = @correct
      @result.incorrect = @incorrect
      @result.test_time = @test_time
      @result.subject = Test.find(session[:test_id]).subject
      @result.save
    end
  end
  def finish_test    
    @var = session[:user_id]
    reset_session
    session[:user_id] = @var
    redirect_to controller: 'users', action: 'home'
  end
  
  def home
    render :layout => 'application'
  end
  
  def test_login
    authorized_test = Test.find_by(testlogin: params[:testlogin],testpass: params[:testpass])
    if authorized_test && !session[:user_id]
      session[:test_id] = authorized_test.id
      flash[:notice] = "Welcome, your test id is #{authorized_test.testlogin}."
      flash[:note] = "Login to Continue"
      redirect_to(:controller => 'users', :action => 'login')
    elsif session[:user_id] && authorized_test
      session[:test_id] = authorized_test.id
      redirect_to(:controller => 'users', :action => 'home')
    else
      flash[:notice] = "Login Id or Password error"
      redirect_to(:action => 'home')
    end    
  end
  
  def edittest
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:controller => 'users', :action => 'login')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You have been logged out Successfully"
      redirect_to(:controller => 'users', :action => 'login')
    else
      session[:temp_id]=params[:test_id]
      @test = Test.find(session[:temp_id])
      render layout: "admin_layout"
    end    
  end
  
  def savetest
    @test = Test.find(session[:temp_id])
    if params[:test][:testpass].blank?
      if @test.update(test_params)
        flash[:notice] = "Test successfully updated"
        redirect_to :controller => 'admin', :action => 'viewtest'
      else
        render :controller => 'tests', :action => 'edittest'
      end
    else
      if @test.update(test_params, :testpass => params[:test][:testpass])
        flash[:notice] = "Test successfully updated"
        redirect_to :controller => 'admin', :action => 'viewtest'
      else
        render :controller => 'tests', :action => 'edittest'
      end
    end    
  end
  
  private
  def test_params
    params.require(:test).permit(:duration, :quescount, :isactive, :testname, :testlogin)
  end
  
end