class Post < ActiveRecord::Base

belongs_to :dashboard

  validates :content, :presence => true,
                      :length   => { :maximum => 140 }
  validates :user_id, :presence => true  
end
