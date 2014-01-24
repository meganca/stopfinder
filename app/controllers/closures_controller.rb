class ClosuresController < ApplicationController
 
  def report
    ids = (params[:id]).split("_")
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid)[0]
  end
  
  def create
    @closure = Closure.new(params[:closure])
    @closure.save
    redirect_to dataentry_url(:id => params[:closure][:AgencyId] + "_" + params[:closure][:StopId])
  end
  
end