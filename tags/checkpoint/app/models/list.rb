class List < ActiveRecord::Base
  
  has_many :items, :foreign_key => "list_id", :dependent => :destroy
                           
  validates :name,  :presence => true,
                    :length   => { :maximum => 50 }

  validates :user_id, :poster_id, :presence => true          
  
end
