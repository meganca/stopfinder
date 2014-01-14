class SessionsController < ApplicationController
  def new
  end
  
  def create
    if session[:user_email]
      render :text => "You are already logged in."
      redirect_to dataview_url(:id => cookies[:stopid])
    else
      # Go get the authorization
      auth_hash = request.env['omniauth.auth']
   
      # Create the session
      session[:user_email] = auth_hash["info"]["email"]
   
      #render :text => "Welcome #{session[:user_email]}!"
      redirect_to dataview_url(:id => cookies[:stopid])
    end
  end
  
  def destroy
    session[:user_email] = nil
    redirect_to dataview_url(:id => cookies[:stopid])
  end
  
  def failure
  end
  
end