class ReputationController < ApplicationController
  def profile
  end
  
  def create
  	  @form_submitted = true
  	  user = User.find_by_id(cookies[:user_id])
 
  	  if (params[:settings][:display_name].length > 20)
  	  	flash[:notice] = "Please keep display name under 20 characters."
  	  else
  	  	user.name = params[:settings][:display_name]
  	  	user.visible = params[:settings][:visible]
  	  	flash[:notice] = "Changes saved."
  	  	user.save
  	  end

  	  redirect_to '/reputation/profile'
  	  
  end
  def publicprofile
    @user = User.find_by_id(params[:id])
    @displayInfo = ""
    
    if(@user == nil)
      @displayInfo = "no user"
    elsif(@user.visible == 0)
      @user = nil
      @displayInfo = "hidden"
    end
  end
  
  def top
    @userList = User.find_by_sql("select * from users where visible=1 order by points desc limit 20")
  end
end
