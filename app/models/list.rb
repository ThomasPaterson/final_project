class List < ActiveRecord::Base
  
  has_many :items, :foreign_key => "list_id", :dependent => :destroy
  has_many :tags, :through => :items
  belongs_to :user
                
  validates :name,  :presence => true,
                    :length   => { :maximum => 50 }

  validates :user_id, :poster_id, :parent_id, :presence => true        
  
  default_scope :order => 'lists.created_at DESC'
  
  attr_accessible :name, :user_id, :poster_id, :event_id, :parent_id
  
end
