class Event < ActiveRecord::Base
  has_event_calendar
  belongs_to :user
  
  has_one :reminder, :foreign_key => "event_id",
  :dependent => :destroy
  
  validates :name,  :presence => true,
                    :length   => { :maximum => 50 }
  validates :start_at, :end_at, :presence => true
  




  
end
