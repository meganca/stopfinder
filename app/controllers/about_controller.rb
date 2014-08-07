class AboutController < ApplicationController
  respond_to :json
  include APIHelper
  
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
  
  def deleted
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
  
  def find
    stopid = params[:stop]
    @stops = BusStop.find(:all, :conditions => ["stopid = ? AND userid = '0'", stopid])
    
    # If we've got nothing, try to treat it as a string
    if @stops.blank?
      searchstring = (params[:stop]).tr('.', '')
      searchstring = searchstring.upcase
      bannedwords = ["ST", "AVE", "RD"]
      
      searchstring = searchstring.split.delete_if{|x| bannedwords.include?(x)}.join(' ')
      streets = searchstring.split(/&|\bAND\b/)
      streets = streets.map{ |x| x.strip}
   
      if streets.length == 2
        @stops = BusStop.where("stopname LIKE :street1 OR stopname LIKE :street2", street1: "%#{streets[0]}% \& %#{streets[1]}%", street2: "%#{streets[1]}% \& %#{streets[0]}%")
      else #Just one street? Do what we can.
        @stops = BusStop.where("stopname LIKE :street1", street1: "% #{streets[0]} %").limit(10)
      end
    end
    
    if @stops.length == 1
      id = @stops[0].AgencyId.to_s + "_" + @stops[0].StopId.to_s
      redirect_to '/busstops/'+id and return
    end
  end
  
  helper_method :busRoutes, :direction
end
