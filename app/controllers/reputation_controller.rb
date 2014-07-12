class ReputationController < ApplicationController
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
    end
  end
  
  def top
    @userList = User.find_by_sql("select * from users where visible=1 order by points desc limit 20")
  end
end
