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
    if @user.save
      session[:user_id] = @user.id
      UserMailer.welcome_email(@user.name, @user.email, @user.password).deliver
      flash[:notice] = "You signed up successfully"
      flash[:color]= "valid"
      redirect_to action: 'home'
    else
      render "new"
    end
  end

  def tryedit
    if params[:commit] == 'Save'  
      @user = User.find(params[:id])  
      if @user.update(user_params)
        flash[:notice] = "Records Updated Successfully"
        flash[:color]= "valid"
        redirect_to action: 'home'
      else
        render 'edit'
      end
    elsif params[:commit] == 'Save User' 
      @user = User.find(session[:temp_id])         
      if @user.update(user_params2)
        flash[:notice] = "Records Updated Successfully"
        flash[:color]= "valid"
        redirect_to action: 'view', controller: 'admin'
      else
        render 'edituser', :layout => 'admin_layout'
      end
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
    @user.password = rand_string
    UserMailer.welcome_email(@user.name, @user.email, @user.password).deliver
    if params[:commit] == 'Create'      
      if @user.save
        flash[:notice] = "New User Created"
        redirect_to action: 'home', controller: 'admin'
      else
        render 'users/adduser', :layout => 'admin_layout'
      end 
    elsif params[:commit] == 'Create and continue'
      render 'users/adduser', :layout => 'admin_layout'
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
    if chk_session
      @user = User.find(session[:user_id])
      render(:layout => "layouts/users")
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
    if chk_session    
      @cuser = User.where("id = '#{session[:user_id]}'")
      render(:layout => "layouts/users")
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
        redirect_to controller: 'users', action: 'edituser', layout: 'admin_layout'
      else
        render 'edituser'
      end
    else
      if @user = User.find_by(email: params[:email])
        @password = rand_string
        UserMailer.reset_pass_email(@user.name, @user.email, @password).deliver
        if @user.update(password: @password)
          flash[:notice] = "Password Reset Successful"
          render action: 'login', layout: 'application'
        else
          flash[:notice] = "Invalid Email- Password Reset Error"
          redirect_to action: 'forgot'
        end
      else
        flash[:notice] = "Invalid Email- Password Reset Error"
        redirect_to action: 'forgot'
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
