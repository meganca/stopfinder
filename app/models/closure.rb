class Closure < ActiveRecord::Base
  self.table_name = "closures"
  attr_accessible :UserId, :AgencyId, :StopId, :UserIP, :UserAtStop, :DateCreated, 
    :ClosureType, :ClosurePermanent, :StartDate, :EndDate, :MovedTo
    
    
  def self.closureStatus(allReports)
    dateReported = Time.new(2000)
      
    if (allReports.any? == false)
      return ["open"]
    end
    
    status = allReports[0].ClosureType
    if (status == "open")
      return ["open"]
    else
      # Current or future closure report
      dateReported = allReports[0].StartDate
      
      allReports.each do |report|
        if (report.ClosurePermanent == "no" && report.ClosureType != "open")
          return ["closed", dateReported.strftime("%B %d, %Y"), report.EndDate.strftime("%B %d, %Y at %I:%M %p")]
        end
      end
    end
    
    # If we haven't otherwise returned, no end date
    return ["closed", dateReported.strftime("%B %d, %Y"), "none"]
  end
  
  
end
