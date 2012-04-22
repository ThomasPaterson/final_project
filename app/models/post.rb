class Post < ActiveRecord::Base
  attr_accessible :content, :user_id, :dashboard_id, :created_at, :updated_at, :reply_to, :is_private
  belongs_to :dashboard
  belongs_to :post, :foreign_key => "reply_to"
  has_many :posts, :foreign_key => "reply_to"

  validates :content, :presence => true,
                      :length   => { :maximum => 140 }
  validates :user_id, :presence => true  
end
