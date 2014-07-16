class SessionsController < ApplicationController
  def new
  end
  
  def create
    if cookies[:user_email]
      render :text => "You are already logged in."
      redirect_to dataview_url(:id => session[:agency_id]+"_"+session[:stop_id])
    else
      # Go get the authorization
      auth_hash = request.env['omniauth.auth']
   
      # Create the session
      cookies[:user_email] = {:value => auth_hash["info"]["email"], :expires => 1.month.from_now}
      
      # Check for existing credentials
      currentUser = User.find_by_email(cookies[:user_email])
      currentAuth = Authorization.find_by_uid(auth_hash["uid"])
      
      if (currentAuth == nil)
        # The first time we log in, we want to make sure the user gets credit for all past submissions
        if (currentUser != nil)
          currentAuth = Authorization.create(uid: auth_hash["uid"], provider: auth_hash["provider"], user_id: currentUser.id)
        else
          currentUser = User.create(name: auth_hash["info"]["name"], email: auth_hash["info"]["email"])
          currentAuth = Authorization.create(uid: auth_hash["uid"], provider: auth_hash["provider"], user_id: currentUser.id)
        end
      end
   
      cookies[:user_id] = {:value => currentUser.id, :expires => 1.month.from_now}
      #render :text => "Welcome #{cookies[:user_email]}!"
      redirect_to dataview_url(:id => session[:agency_id]+"_"+session[:stop_id])
    end
  end
  
  def destroy
    cookies.delete(:user_email)
    cookies.delete(:user_id)
    redirect_to dataview_url(:id => session[:agency_id]+"_"+session[:stop_id])
  end
  
  def failure
  end
  
end