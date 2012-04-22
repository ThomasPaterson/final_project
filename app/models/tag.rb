class Tag < ActiveRecord::Base

  belongs_to :item 
  belongs_to :event
  belongs_to :user

  validates :name, :presence => true,
                      :length   => { :maximum => 50 }
  validates :user_id, :event_id, :item_id, :presence => true 

  attr_accessible :name, :user_id, :event_id, :item_id
  
  
end
