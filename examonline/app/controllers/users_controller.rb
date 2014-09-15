class UsersController < ApplicationController
  layout "application", :only => [:new, :login, :create]
  
  def new
    @user = User.new
  end
  
  def destroy_multiple
    if params[:users]
      User.destroy(params[:users])
    else
      flash[:notice] = "No records selected"
    end
    redirect_to action: 'view', controller: 'admin'
  end

  def create
    @user = User.new(user_params)
    @user.usertype = 'Examinee'
    @user.activity = 'Active'
    @pass = @user.password
    puts @pass
    if @user.save
      session[:user_id] = @user.id
      UserMailer.welcome_email(@user.name, @user.email, @pass).deliver
      flash[:notice] = "You signed up successfully"
      flash[:color]= "valid"
      redirect_to action: 'home'
    else
      render "new"
    end
  end
  
  def editself
    @user = User.find(params[:id])  
    if @user.update(user_params)
      flash[:notice] = "Records Updated Successfully"
      flash[:color]= "valid"
      redirect_to action: 'home'
    else
      if User.find(session[:user_id]).usertype == 'Admin'
        render :action => 'edit', :layout => 'admin_layout'
      else
        render :action => 'edit'
      end
    end
  end

  def tryedit
    @user = User.find(session[:temp_id])         
    if @user.update(user_params2)
      flash[:notice] = "Records Updated Successfully"
      flash[:color]= "valid"
      redirect_to action: 'view', controller: 'admin'
    else
      render 'edituser', :layout => 'admin_layout'
    end
  end

  def login
  end
  
  def adduser
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')
    else
      @user = User.new
      render(:layout => "layouts/admin_layout")
    end
  end
  
  def addnew
    @user = User.new(user_params2)
    @pass = rand_string
    @user.password = @pass
    if params[:commit] == 'Create'      
      if @user.save
        UserMailer.welcome_email(@user.name, @user.email, @pass).deliver
        flash[:notice] = "New User Created"
        redirect_to action: 'home', controller: 'admin'
      else
        render 'users/adduser', :layout => 'admin_layout'
      end 
    elsif params[:commit] == 'Create and continue'
      if @user.save
        flash[:notice] = "New User Created"
        render 'users/adduser', :layout => 'admin_layout'
      else
        render 'users/adduser', :layout => 'admin_layout'
      end
    end
  end
  
  def logout
    reset_session
    flash[:notice] = "You Successfully logged Out"
    redirect_to(:controller => 'tests', :action => 'home')
  end

  def login_attempt
    authorized_user = User.authenticate(params[:email],params[:login_password])
    if authorized_user
      session[:user_id] = authorized_user.id
      flash[:notice] = "Welcome, you logged in as #{authorized_user.name}"
      redirect_to(:action => 'home')
    else
      flash[:notice] = "Invalid Username or Password"
      redirect_to(:action => 'login')
    end
  end

  def edit
    case chk_session
    when 'Examinee'
      @user = User.find(session[:user_id])
      render(:layout => "layouts/users")
    when 'Admin'
      @user = User.find(session[:user_id])
      render(:layout => "layouts/admin_layout")
    else
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller => 'users')
    end
  end
  
  def edituser
    if !session[:user_id]
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller=>'users')
    elsif !(User.find(session[:user_id]).usertype == 'Admin')
      reset_session
      flash[:notice] = "You were successfully logged out"
      redirect_to(:controller => 'users', :action => 'login')
    else
      session[:temp_id]=params[:user_id]
      @user = User.find(session[:temp_id])
      render(:layout => "layouts/admin_layout")
    end
  end
  
  def profile
    case chk_session    
    when 'Examinee'
      @cuser = User.where("id = '#{session[:user_id]}'")
      render(:layout => "layouts/users")
    when 'Admin'
      @cuser = User.where("id = '#{session[:user_id]}'")
      render(:layout => "layouts/admin_layout")
    else
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller => 'users')
    end
  end

  def home
    case chk_session
    when 'Admin'
      redirect_to(:controller => 'admin', :action => 'home')
    when 'Examiner'
      flash[:notice] = "Your page is under construction"
      redirect_to(:controller => 'users', :action => 'home')
    when 'Examinee'
      @correct = 0
      @incorrect = 0
      @results = Result.where(user_id: session[:user_id]).paginate(:page => params[:page], :per_page => 5)
      Result.where(user_id: session[:user_id]).each do |res|
        @correct += res.correct.to_i
        @incorrect += res.incorrect.to_i
      end
      if @correct + @incorrect > 0
        @avg = (@correct * 100)/(@correct + @incorrect)
      end
      render(:layout => "layouts/users")
    else
      flash[:notice] = "You Need to Log In First"
      redirect_to(:action => 'login', :controller => 'users')
    end    
  end
  
  def chk_session
    if session[:user_id]
      return User.find(session[:user_id]).usertype
    else
      return false
    end
  end

  def forgot
    render layout: 'application'
  end
  
  def reset_pass
    if session[:temp_id]
      @user = User.find(session[:temp_id])
      @password = rand_string
      UserMailer.reset_pass_email(@user.name, @user.email, @password).deliver
      if @user.update(password: @password)
        flash[:notice] = "Password Reset Successful"
        flash[:color]= "valid"
      end
      redirect_to  action: 'edituser', layout: 'admin_layout'
    else
      if @user = User.find_by(email: params[:email])
        @password = rand_string
        UserMailer.reset_pass_email(@user.name, @user.email, @password).deliver
        if @user.update(password: @password)
          flash[:notice] = "Password Reset Successful"
          render action: 'login', layout: 'application'
        else
          flash[:notice] = "Invalid Email- Password Reset Error"
          redirect_to action: 'forgot', layout: 'application'
        end
      else
        flash[:notice] = "Invalid Email- Password Reset Error"
        redirect_to action: 'forgot', layout: 'application'
      end
    end
  end
  
  private
  def user_params
    params.require(:user).permit(:name, :email, :experience, :phone, :password, :password_confirmation)
  end
  def user_params2
    params.require(:user).permit(:name, :email, :experience, :phone, :usertype, :activity)
  end
  def rand_string
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten
    string = (0...8).map { o[rand(o.length)] }.join
    return string
  end  
  
end
