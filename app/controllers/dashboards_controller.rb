class DashboardsController < ApplicationController
  before_filter :authenticate, :except => [:new, :create]
    
  def new
    @dashboard = Dashboard.new
  end

  def create
    @dashboard = Dashboard.new(params[:dashboard])

    if @dashboard.save
      redirect_to @dashboard, notice: 'Dashboard was successfully created.'
    else
      render action: "new"
    end
  end

  def destroy
    @dashboard = Dashboard.find(params[:id])
    @dashboard.destroy

    redirect_to dashboards_url
  end
end
