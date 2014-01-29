class LogsController < ApplicationController
 
  def record(update)
    if session[:bearing_code][:needs_verification] == "true"
      update.direction = "needs verification"
    else
      update.direction = session[:bearing_code][:value]
    end
      
    if session[:intersection_pos][:needs_verification] == "true"
      update.position = "needs verification"
    else
      update.position = session[:intersection_pos][:value] 
    end
      
    if session[:sign_type][:needs_verification] == "true" 
      update.sign_type = "needs verification"
    else
      update.position = session[:sign_type][:value]
    end
      
    if session[:curb_inset][:needs_verification] == "true" 
      update.sign_position = "needs verification"
    else
      update.sign_position = session[:curb_inset][:value]
    end
      
    if session[:sched_holder][:needs_verification] == "true" 
      update.schedule_holder = "needs verification"
    else
      update.schedule_holder = session[:sched_holder][:value]
    end
    
    if session[:shelter_count][:needs_verification] == "true" 
      update.shelters = "needs verification"
    else
      update.shelters = session[:shelter_count][:value]
    end
      
    if session[:bench_count][:needs_verification] == "true"
      update.benches = "needs verification"
    else
      update.benches = session[:bench_count][:value]
    end
      
    if session[:can_count][:needs_verification] == "true" 
      update.trash_can = "needs verification"
    else
      update.trash_can = session[:can_count][:value]
    end
    
    update.save
    
  end
  
end