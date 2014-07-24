class AboutController < ApplicationController
  def main
    showLog = BusStop.usageLogger
    showLog.info("Viewed main info page at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Opened by user #{session[:device_id]}")
    end

    if(cookies[:user_email])
      showLog.info("User logged in as #{cookies[:user_email]}")
    end
    
    showLog.info("")
    
  end
  
  def contact
  end
  
  def create
 	 stop = params[:search][:stop_num]
 	
 	 if (stop != nil && stop != "")
	 	 redirect_to '/busstops/1_' + stop.to_s
	 else
	 	redirect_to '/'
	 end
  end
  
  def entry
  end
  
  def faq
  end
  
  def irb
  end
  
  def data
    showLog = BusStop.usageLogger
    showLog.info("Viewed field info page at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Opened by user #{session[:device_id]}")
    end

    if(cookies[:user_email])
      showLog.info("User logged in as #{cookies[:user_email]}")
    end
    
    showLog.info("")
  end
  
  def testing
    showLog = BusStop.usageLogger
    showLog.info("Access from out-of-region request at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Opened by user #{session[:device_id]}")
    end

    if(cookies[:user_email])
      showLog.info("User logged in as #{cookies[:user_email]}")
    end
    
    showLog.info("")
  end
  
  def missing
  end
  
  def repeat
  end
end
