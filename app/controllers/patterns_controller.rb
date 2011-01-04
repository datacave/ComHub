class PatternsController < ApplicationController
  # GET /patterns
  # GET /patterns.xml
  def index
    @patterns = Pattern.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patterns }
    end
  end

  # GET /patterns/1
  # GET /patterns/1.xml
  def show
    @pattern = Pattern.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pattern }
    end
  end

  # GET /patterns/new
  # GET /patterns/new.xml
  def new
    @pattern = Pattern.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pattern }
    end
  end

  # GET /patterns/1/edit
  def edit
    @pattern = Pattern.find(params[:id])
  end

  # POST /patterns
  # POST /patterns.xml
  def create
    @pattern = Pattern.new(params[:pattern])

    respond_to do |format|
      if @pattern.save
        flash[:notice] = 'Pattern was successfully created.'
        format.html { redirect_to(@pattern) }
        format.xml  { render :xml => @pattern, :status => :created, :location => @pattern }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pattern.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patterns/1
  # PUT /patterns/1.xml
  def update
    @pattern = Pattern.find(params[:id])

    respond_to do |format|
      if @pattern.update_attributes(params[:pattern])
        flash[:notice] = 'Pattern was successfully updated.'
        format.html { redirect_to(@pattern) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pattern.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patterns/1
  # DELETE /patterns/1.xml
  def destroy
    @pattern = Pattern.find(params[:id])
    @pattern.destroy

    respond_to do |format|
      format.html { redirect_to(patterns_url) }
      format.xml  { head :ok }
    end
  end
end
