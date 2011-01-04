class TimeWindowsController < ApplicationController
  # GET /time_windows
  # GET /time_windows.xml
  def index
    @time_windows = TimeWindow.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @time_windows }
    end
  end

  # GET /time_windows/1
  # GET /time_windows/1.xml
  def show
    @time_window = TimeWindow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @time_window }
    end
  end

  # GET /time_windows/new
  # GET /time_windows/new.xml
  def new
    @time_window = TimeWindow.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @time_window }
    end
  end

  # GET /time_windows/1/edit
  def edit
    @time_window = TimeWindow.find(params[:id])
  end

  # POST /time_windows
  # POST /time_windows.xml
  def create
    @time_window = TimeWindow.new(params[:time_window])

    respond_to do |format|
      if @time_window.save
        flash[:notice] = 'TimeWindow was successfully created.'
        format.html { redirect_to(@time_window) }
        format.xml  { render :xml => @time_window, :status => :created, :location => @time_window }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @time_window.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /time_windows/1
  # PUT /time_windows/1.xml
  def update
    @time_window = TimeWindow.find(params[:id])

    respond_to do |format|
      if @time_window.update_attributes(params[:time_window])
        flash[:notice] = 'TimeWindow was successfully updated.'
        format.html { redirect_to(@time_window) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @time_window.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /time_windows/1
  # DELETE /time_windows/1.xml
  def destroy
    @time_window = TimeWindow.find(params[:id])
    @time_window.destroy

    respond_to do |format|
      format.html { redirect_to(time_windows_url) }
      format.xml  { head :ok }
    end
  end
end
