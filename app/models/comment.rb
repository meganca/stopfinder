class Comment < ActiveRecord::Base
  attr_accessible :agency_id, :stop_id, :info
  
  self.primary_keys = :agency_id, :stop_id

  def self.add_or_edit(agencyId, stopId, contents)
    if find_by_agency_id_and_stop_id(agencyId, stopId) == nil
      newComment = Comment.create :agency_id => agencyId, :stop_id => stopId, :info => contents
      newComment.save
    else
      oldComment = Comment.find(agencyId, stopId)
      oldComment.destroy
      newComment = Comment.create :agency_id => agencyId, :stop_id => stopId, :info => contents
      newComment.save
    end
  end
  
end
