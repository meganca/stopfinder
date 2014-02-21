class AboutController < ApplicationController
  def main
    showLog = BusStop.usageLogger
    showLog.info("Viewed main info page at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Opened by user #{session[:device_id]}")
    end

    if(session[:user_email])
      showLog.info("User logged in as #{session[:user_email]}")
    end
    
    showLog.info("")
  end
  
  def contact
  end
  
  def entry
  end
  
  def irb
  end
  
  def data
    showLog = BusStop.usageLogger
    showLog.info("Viewed field info page at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Opened by user #{session[:device_id]}")
    end

    if(session[:user_email])
      showLog.info("User logged in as #{session[:user_email]}")
    end
    
    showLog.info("")
  end
  
  def testing
    showLog = BusStop.usageLogger
    showLog.info("Access from out-of-region request at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Opened by user #{session[:device_id]}")
    end

    if(session[:user_email])
      showLog.info("User logged in as #{session[:user_email]}")
    end
    
    showLog.info("")
  end
  
  def missing
  end
  
  def checkDevice() 
    if browser.safari?
      @browser = :safari
    else
      @browser = :other
    end
  end
end
