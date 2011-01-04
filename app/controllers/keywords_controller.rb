class KeywordsController < ApplicationController
  # GET /keywords
  # GET /keywords.xml
  def index
    @keywords = Keyword.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @keywords }
    end
  end

  # GET /keywords/1
  # GET /keywords/1.xml
  def show
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @keyword }
    end
  end

  # GET /keywords/new
  # GET /keywords/new.xml
  def new
    @keyword = Keyword.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @keyword }
    end
  end

  # GET /keywords/1/edit
  def edit
    @keyword = Keyword.find(params[:id])
  end

  # POST /keywords
  # POST /keywords.xml
  def create
		# Need to make this use acts_as_nested_set...
		parent_id = params[:parent][:id] || 1
		@parent = Keyword.find(parent_id)
		@keyword = Keyword.create(params[:keyword])
		@parent.add_child(@keyword)

    respond_to do |format|
      if @keyword.save
        flash[:notice] = 'Keyword was successfully created.'
        format.html { redirect_to(@keyword) }
        format.xml  { render :xml => @keyword, :status => :created, :location => @keyword }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /keywords/1
  # PUT /keywords/1.xml
  def update
    @keyword = Keyword.find(params[:id])

    respond_to do |format|
      if @keyword.update_attributes(params[:keyword])
        flash[:notice] = 'Keyword was successfully updated.'
        format.html { redirect_to(@keyword) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.xml
  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy

    respond_to do |format|
      format.html { redirect_to(keywords_url) }
      format.xml  { head :ok }
    end
  end

	def tree
	  @keyword = Keyword.find_by_designation("Everything")
	end
	
end
