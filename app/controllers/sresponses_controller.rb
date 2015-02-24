class SresponsesController < ApplicationController
  def surveyform
  end
  
  def create
    @survey = Sresponse.new(params[:sresponse])
  
    # If you want to do any manipulating things before writing it to the db, do it here
    
    @survey.save
    redirect_to surveyresponse_url
  end
  
end