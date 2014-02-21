class ClosuresController < ApplicationController
 
  def report
    ids = (params[:id]).split(/[_?=&]/)
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid)[0]
    
    showLog = BusStop.usageLogger
    showLog.info("Viewing closure report form for #{agencyid}_#{stopid} at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Accessed by user #{session[:device_id]}")
    end

    if(session[:user_email])
      showLog.info("User logged in as #{session[:user_email]}")
    end
    
    showLog.info("")
  end
  
  def create
    @report = Closure.new(params[:closure])
    
    # If the closure is permanent or unknown, enddate is infinity (a year from now)
    if (@report.ClosureType == "open")
      @report.EndDate = Time.now + 31560000      
      @report.StartDate = Time.now
    elsif (@report.ClosureType == "current")
      @report.StartDate = Time.now
    elsif (@report.ClosureType == "future")
      #@report.StartDate = @report.StartDate.in_time_zone("")
    end
    
    if (@report.ClosurePermanent == "no")
      #@report.EndDate = @report.EndDate.utc
    else
      @report.EndDate = Time.now + 31560000
    end
    
    @report.save
    
    showLog = BusStop.usageLogger
    showLog.info("Submitted closure report form for #{params[:closure][:AgencyId]}_#{params[:closure][:StopId]} at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Submitted by user #{session[:device_id]}")
    end

    if(session[:user_email])
      showLog.info("User logged in as #{session[:user_email]}")
    end
    
    showLog.info("")
    
    redirect_to dataentry_url(:id => params[:closure][:AgencyId] + "_" + params[:closure][:StopId])
  end
  
end