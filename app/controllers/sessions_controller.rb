class SessionsController < ApplicationController
  def new
  end
  
  def create
    if cookies[:user_email]
      render :text => "You are already logged in."
      redirect_to dataview_url(:id => session[:agency_id]+"_"+session[:stop_id], :direction => session[:bearing])
    else
      # Go get the authorization
      auth_hash = request.env['omniauth.auth']
   
      # Create the session
      cookies[:user_email] = {:value => auth_hash["info"]["email"], :expires => 1.month.from_now}
   
      #render :text => "Welcome #{cookies[:user_email]}!"
      redirect_to dataview_url(:id => session[:agency_id]+"_"+session[:stop_id], :direction => session[:bearing])
    end
  end
  
  def destroy
    cookies.delete(:user_email)
    redirect_to dataview_url(:id => session[:agency_id]+"_"+session[:stop_id], :direction => session[:bearing])
  end
  
  def failure
  end
  
end