class ReputationController < ApplicationController
 
  def badges
  end
  
  def create
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
  
  def profile
  end
  
  def publicprofile
    @user = User.find_by_id(params[:id])
    @displayInfo = ""
    
    if(@user == nil)
      @displayInfo = "no user"
    elsif(@user.visible == 0)
      @user = nil
      @displayInfo = "hidden"
    elsif(@user == User.find_by_id(cookies[:user_id]))
      @displayInfo = "same user"
    end
  end
  
  def top
    @userList = User.find_by_sql("select t.*, (select count(*) from users x where x.visible=1 AND x.points > t.points) AS position from users t where t.visible = 1 order by t.points desc")
  end
end
