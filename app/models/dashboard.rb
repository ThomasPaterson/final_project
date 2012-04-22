class Dashboard < ActiveRecord::Base
attr_accessible :user_id, :updated_at
belongs_to :user
has_many :posts

accepts_nested_attributes_for :posts

attr_accessible :user_id
end
