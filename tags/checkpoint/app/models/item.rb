class Item < ActiveRecord::Base
	
  has_one :list

  validates :content, :presence => true,
                      :length   => { :maximum => 140 }
  validates :user_id, :list_id, :presence => true   
  
end
