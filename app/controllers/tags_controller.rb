class TagsController < ApplicationController
before_filter :authenticate
before_filter :correct_user_or_friend




  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  #shows all the tags with this paticular name, based on item and event ids
  def show
  	
  	#select the current filters based on the url to current page
  	@url = request.fullpath
  	
  	if !(@url.include?("listfilter=true"))
  	  @listfilter = false
  	else
  	  @listfilter = true
  	end
  	
  	if !(@url.include?("eventfilter=true"))
  	  @eventfilter = false
  	else
  	  @eventfilter = true
  	end

  	@tag = Tag.find(params[:id])
  	
    @list_tags = Tag.paginate  :per_page => 10, :page => params[:page],
                            	:conditions => '(name like "' + @tag.name + '" AND event_id = 0)',
                            	:order => 'created_at'	

    @event_tags = Tag.paginate  :per_page => 10, :page => params[:page],
                            	:conditions => '(name like "' + @tag.name + '" AND item_id = 0)',
                            	:order => 'created_at'

  end






  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html { render action: "new" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to tags_url }
      format.json { head :ok }
    end
  end
end
