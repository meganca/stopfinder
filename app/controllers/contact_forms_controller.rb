class ContactFormsController < ApplicationController
  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(params[:contact_form])
      @contact_form.request = request
      if @contact_form.deliver
        #flash.now[:notice] = 'Thank you for your interest!'
        #redirect_to root_path
        redirect_to emailentry_url(:id => session[:agency_id] + "_" + session[:stop_id])
      else
        render :new
      end
    rescue ScriptError
      flash[:error] = 'Sorry, something was wrong.'
  end
  
end
