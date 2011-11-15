class AcknowledgmentsController < ApplicationController

	protect_from_forgery :except => :remote

	# GET /acknowledgments
  # GET /acknowledgments.xml
  def index
    @acknowledgments = Acknowledgment.paginate :page => params[:page],
			:order => "created_at DESC", :per_page => 15

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @acknowledgments }
    end
  end

  # GET /acknowledgments/1
  # GET /acknowledgments/1.xml
  def show
    @acknowledgment = Acknowledgment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @acknowledgment }
    end
  end

  # GET /acknowledgments/new
  # GET /acknowledgments/new.xml
  def new
    @acknowledgment = Acknowledgment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @acknowledgment }
    end
  end

  # GET /acknowledgments/1/edit
  def edit
    @acknowledgment = Acknowledgment.find(params[:id])
  end

  # POST /acknowledgments
  # POST /acknowledgments.xml
  def create
    @acknowledgment = Acknowledgment.new(params[:acknowledgment])

    respond_to do |format|
      if @acknowledgment.save
        flash[:notice] = 'Acknowledgment was successfully created.'
        format.html { redirect_to(@acknowledgment) }
        format.xml  { render :xml => @acknowledgment, :status => :created, :location => @acknowledgment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @acknowledgment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /acknowledgments/1
  # PUT /acknowledgments/1.xml
  def update
    @acknowledgment = Acknowledgment.find(params[:id])

    respond_to do |format|
      if @acknowledgment.update_attributes(params[:acknowledgment])
        flash[:notice] = 'Acknowledgment was successfully updated.'
        format.html { redirect_to(@acknowledgment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @acknowledgment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /acknowledgments/1
  # DELETE /acknowledgments/1.xml
  def destroy
    @acknowledgment = Acknowledgment.find(params[:id])
    @acknowledgment.destroy

    respond_to do |format|
      format.html { redirect_to(acknowledgments_url) }
      format.xml  { head :ok }
    end
  end

  def remote
		temp = {}
		temp.store(:body, params[:Body])
		temp.store(:to, params[:To])
		temp.store(:from, params[:From])
		temp.store(:status, params[:SmsStatus])
		temp.store(:uid, params[:SmsSid])
    @ack = Acknowledgment.new(temp)

    respond_to do |format|
      if @ack.save
        flash[:notice] = 'Acknowledgment was successfully created.'
        format.html { render :text => "Affirmative." }
        format.xml  { render :xml => @ack, :status => :created, :location => @ack }
      else
        format.html { render :text => "Negative!" }
        format.xml  { render :xml => @ack.errors, :status => :unprocessable_entity }
      end
    end
  end

end
