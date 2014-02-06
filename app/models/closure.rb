class Closure < ActiveRecord::Base
  self.table_name = "closures"
  attr_accessible :UserId, :AgencyId, :StopId, :UserIP, :UserAtStop, :DateCreated, 
    :ClosureType, :ClosurePermanent, :StartDate, :EndDate, :MovedTo
    
    
  def self.isCurrent(type, permanent, startdate, enddate)
    if ((type == nil) || (type == ""))
      return "false"
    elsif (type == "current")
      if (permanent == "yes")
        return "true"
      elsif (enddate > Date.today)
        return "true"
      else
        return "false"
      end
    elsif (type == "future" && startdate < Date.today)
      if (permanent == "yes")
        return "true"
      elsif (enddate > Date.today)
        return "true"
      else
        return "false"
      end
    else
      return "false"
    end
  end
  
  
end
