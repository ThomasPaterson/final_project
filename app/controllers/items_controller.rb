class ItemsController < ApplicationController
  
	before_filter :authenticate


  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  #create tags for items with array passed at same time
  def create
    @item = Item.new(params[:item])
    @list = List.find(@item.list_id)
    @item.user_id = @list.user_id
    if (@list.parent_id != 0)
    	@item.list_id = @list.parent_id
    end
    
    if @item.save
      @tags = (params[:tag][:text]).split(",")
      @tags << "#{@item.content}"
      @tags = @tags.uniq
      @tags.each do |tag|
      	@item.create_item_tag!(tag)
      end
      redirect_to :back
    else
      redirect_to :back
    end
  end



  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :ok }
    end
  end

  def destroy_item
    destroy
  end
  
end
