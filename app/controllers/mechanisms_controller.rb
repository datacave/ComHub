class MechanismsController < ApplicationController
  # GET /mechanisms
  # GET /mechanisms.xml
  def index
    @mechanisms = Mechanism.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mechanisms }
    end
  end

  # GET /mechanisms/1
  # GET /mechanisms/1.xml
  def show
    @mechanism = Mechanism.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mechanism }
    end
  end

  # GET /mechanisms/new
  # GET /mechanisms/new.xml
  def new
    @mechanism = Mechanism.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mechanism }
    end
  end

  # GET /mechanisms/1/edit
  def edit
    @mechanism = Mechanism.find(params[:id])
  end

  # POST /mechanisms
  # POST /mechanisms.xml
  def create
    @mechanism = Mechanism.new(params[:mechanism])

    respond_to do |format|
      if @mechanism.save
        flash[:notice] = 'Mechanism was successfully created.'
        format.html { redirect_to(@mechanism) }
        format.xml  { render :xml => @mechanism, :status => :created, :location => @mechanism }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mechanism.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mechanisms/1
  # PUT /mechanisms/1.xml
  def update
    @mechanism = Mechanism.find(params[:id])

    respond_to do |format|
      if @mechanism.update_attributes(params[:mechanism])
        flash[:notice] = 'Mechanism was successfully updated.'
        format.html { redirect_to(@mechanism) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mechanism.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mechanisms/1
  # DELETE /mechanisms/1.xml
  def destroy
    @mechanism = Mechanism.find(params[:id])
    @mechanism.destroy

    respond_to do |format|
      format.html { redirect_to(mechanisms_url) }
      format.xml  { head :ok }
    end
  end
end
