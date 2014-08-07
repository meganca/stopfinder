class ApplicationController < ActionController::Base
  protect_from_forgery
  
  module APIHelper
  
    def direction(agencyid, stopid)
      apiURI = "http://api.pugetsound.onebusaway.org/api/where/stop/" + agencyid + "_" + stopid + ".json?key=693c0a55-9ef0-4302-8bc3-f9b2db93e124"
      dbStops = BusStop.find(:all, :conditions => ["stopid = ? AND userid = '0'", stopid])
      
      begin
        response = Net::HTTP.get_response(URI.parse(apiURI))
        data = response.body
        hash = JSON.parse(data)
        
        if hash["code"] == 200
          return hash["data"]["entry"]["direction"]
        elsif hash["code"] == 404
          if dbStops.nil?
            return
          else
            return dbStops[0].BearingCode
          end
        end
      rescue
        retry
      end
    end
    
    def busRoutes(agencyid, stopid)
      apiURI = "http://api.pugetsound.onebusaway.org/api/where/stop/" + agencyid + "_" + stopid + ".json?key=693c0a55-9ef0-4302-8bc3-f9b2db93e124"
      
      begin
        response = Net::HTTP.get_response(URI.parse(apiURI))
        data = response.body
        hash = JSON.parse(data)
        
        if hash["code"] == 200
          routes = []
          
          hash["data"]["routes"].each do |route| 
            routes.push(route["shortName"])
          end
          
          return routes
        elsif hash["code"] == 404
          return ["inactive stop"]
        end
      rescue
        retry
      end
    end
    
  end

end
