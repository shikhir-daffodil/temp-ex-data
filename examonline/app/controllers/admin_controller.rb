class AdminController < ApplicationController
  layout "admin_layout"
  def home
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')    
    end
  end
  
  def view
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')
    else
      if params[:commit] == "Apply"
        @filteredusers = userfilter(params[:name], params[:email], params[:exp], params[:expval], params[:phone], params[:usertype])
        @users = @filteredusers.paginate(:page => params[:page], :per_page => 10)
      else
        @users = User.all.paginate(:page => params[:page], :per_page => 10)
      end
    end
  end
  
  def userfilter(name, email, exp, expval, phone, usertype)
    if expval.blank?
      expval = 0
    end
    @users = User.all.where("email LIKE (?)", "#{email}%").where("name LIKE (?)", "#{name}%").where("experience #{exp}#{expval}").where("phone LIKE (?)", "#{phone}%").where("usertype LIKE (?)", "#{usertype}%")
    return @users
  end
  
  def destroyuser
    if session[:user_id].to_s == params[:id].to_s
      flash[:notice] = "Can't delete Logged In User"
      redirect_to :action => 'view', :controller => 'admin'      
    else
      @user = User.where(id: params[:id]).first
      if @user 
        @user.destroy
        flash[:success] = "User deleted"
      else
        flash[:notice] = "No User found"        
      end
      redirect_to :action => 'view', :controller => 'admin'
    end
  end
  
  def newques
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')
    else
      @question = Question.new
      @options = QuestionOption.new
      @subject = Subject.all
    end
  end
  
  def addques
    answers = params[:answers].split(",")
    answers = answers.collect{|x| x = x.strip}
    ans = Array.new
    x = 0
    chk = false
    @question = Question.new(:ques => params[:ques], :quetype => params[:quetype][:sub], :multichoice => params[:multichoice], :isactive => params[:isactive])
    if @question.save      
      params[:options].each do |key, opt|
        @option = @question.question_options.create(:option => opt)
        if @option.save && !opt.blank?
          chk = true
        else
          flash[:notice] = "Blank option not allowed"
          chk = false
          break
        end
        if answers.include?(opt)
          ans[x]=@option.id
          x=x+1
        end
      end
      c = ans.join(",")
      answer = Question.find(@question.id)
      answer.update(answers: c)
      if ans.empty? || (params[:answers].include?(",") && params[:multichoice] == "No")
        chk = false
        flash[:notice] = "Empty or invalid answers"
        delques = Question.find(@question.id)
        delques.destroy
      end
    end
    if chk
      flash[:notice] = "New Question Added Successfully"
      redirect_to :action => 'newques'
    else
      render 'newques'
    end    
  end
  
  def viewquestions
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')
    else      
      @questions = Question.all.paginate(:page => params[:page], :per_page => 5)
    end
  end
  
  def deletequestion
    Question.find(params[:id]).destroy
    flash[:success] = "Question deleted."
    redirect_to :action => 'viewquestions', :controller => 'admin'    
  end
  
  def del_mul_ques
    if params[:questions]
      Question.destroy(params[:questions])
    else
      flash[:notice] = "No records selected"
    end
    redirect_to action: 'viewquestions', controller: 'admin'    
  end
  
  def editquestion
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:controller => 'users', :action => 'login')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You have been logged out Successfully"
      redirect_to(:controller => 'users', :action => 'login')
    else
      session[:temp_id]=params[:question_id]
      @question = Question.find(session[:temp_id])
    end    
  end
  
  def update
    answers = params[:answers].split(",")
    answers = answers.collect{|x| x = x.strip}
    ans = Array.new
    i = 0
    chk = false
    @question = Question.find(session[:temp_id])
    if @question.update(:ques => params[:question][:ques], :quetype => params[:quetype][:sub], :multichoice => params[:question][:multichoice], :isactive => params[:question][:isactive])
      @options = @question.question_options.where(question_id: session[:temp_id])
      var_opt = Array.new
      params[:options].each do |key, val|
        var_opt.push(val)
      end
      len = var_opt.length
      var = 0
      @options.each do |opt|
        puts var_opt[var]
        if !var_opt[var].blank?
          if var < len
            @option = QuestionOption.find(opt.id)
            @option.update(:option => var_opt[var].strip)
            var = var + 1
            chk = true
          end
        else
          flash[:notice] = "Blank option not allowed"
          chk = false
          break
        end
      end
      @options = @question.question_options.where(question_id: session[:temp_id])
      @options.each do |opt|
        if answers.include?(opt.option)
          ans[i]=opt.id
          i=i+1
        end        
      end
    end
    c = ans.join(",")
    if ans.empty? || (params[:answers].include?(",") && params[:question][:multichoice] == "No")
      chk = false
      flash[:notice] = "Empty or invalid answers"
    else
      answer = Question.find(session[:temp_id])
      answer.update(answers: c)      
    end    
    if chk
      flash[:notice] = "Question Updated Successfully"
      redirect_to :action => 'viewquestions'
    else
      render 'editquestion'
    end
  end
  
  def addtest
    @test = Test.new(test_params)
    @test.createdby = session[:user_id]
    if @test.save
      flash[:notice] = "New Test Created"
      redirect_to :action => 'newtest'
    else
      render "newtest"
    end    
  end
  
  def newtest
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')
    else
      @test = Test.new
    end    
  end
  
  def viewtest
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')
    else      
      @tests = Test.all.paginate(:page => params[:page], :per_page => 5)
    end    
  end
  
  def destroy_multipletest
    if params[:tests]
      params[:tests].each do |test|
        Test.destroy(test)
      end
    else
      flash[:notice] = "No records selected"
    end
    flash[:notice] = "Selected Tests successfully deleted"
    redirect_to action: 'viewtest', controller: 'admin'
  end
  
  def stats
    @stats = Result.all.paginate(:page => params[:page], :per_page => 10)
  end
  
  def csv_actions
    @questions = Question.all
    respond_to do |format|
      format.html
      format.csv { send_data @questions.to_csv }
    end
  end
  
  def importQuestions
    Question.import(params[:file])
    redirect_to action: csv_actions, notice: "Products Successfully Imported"
  end
  
  private
  def test_params
    params.require(:test).permit(:subject, :duration, :quescount, :isactive, :testname, :testlogin, :testpass)
  end
    
end
