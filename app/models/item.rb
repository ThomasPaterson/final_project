class Item < ActiveRecord::Base
	
  belongs_to :list
  has_many :tags, :foreign_key => "item_id", :dependent => :destroy

  validates :content, :presence => true,
                      :length   => { :maximum => 140 }
  validates :user_id, :list_id, :presence => true   
  
  attr_accessible :content, :list_id, :user_id
  
  
  def create_item_tag!(tag)
  	Tag.create(:name => tag.to_s.strip, :user_id => user_id, :item_id => id, :event_id => 0)
  end
  
  def get_tags
  	@tags = Tag.where(:item_id => id)
  end
  
  def get_list_name
  	@list = List.where(:id => list_id)
  	@list.name
  end
  
end
