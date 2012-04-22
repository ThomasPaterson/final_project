class Event < ActiveRecord::Base
  has_event_calendar
  belongs_to :user
  
  has_one :reminder, :foreign_key => "event_id", :dependent => :destroy
  has_many :tag, :foreign_key => "event_id", :dependent => :destroy
  
  validates :name,  :presence => true,
                    :length   => { :maximum => 50 }
  validates :start_at, :end_at, :presence => true
  
  validate :start_at_before_end_at
  
  attr_accessible :name, :start_at, :end_at, :description, :all_day, :is_public, :user_id, :poster_id, :confirmed

  def start_at_before_end_at
  	if (start_at > end_at)
  		errors.add('Start date', 'must be before the end date.')
  	end
  end

  def create_item_tag!(tag)
  	Tag.create!(:name => tag.to_s.strip, :user_id => user_id, :item_id => 0, :event_id => id)
  end

  def get_tags
  	@tags = Tag.where(:event_id => id)
  end
end
