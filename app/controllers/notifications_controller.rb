class NotificationsController < ApplicationController

	protect_from_forgery :except => :confirm

  # GET /notifications
  # GET /notifications.xml
  def index
    #@notifications = Notification.all
		@notifications = Notification.paginate :order => "created_at DESC",
			:page => params[:page], :per_page => 15
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notifications }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.xml
  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notification }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.xml
  def new
    @notification = Notification.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notification = Notification.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.xml
  def create
    @notification = Notification.new(params[:notification])

    respond_to do |format|
      if @notification.save
        flash[:notice] = 'Notification was successfully created.'
        format.html { redirect_to(@notification) }
        format.xml  { render :xml => @notification, :status => :created, :location => @notification }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.xml
  def update
    @notification = Notification.find(params[:id])

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        flash[:notice] = 'Notification was successfully updated.'
        format.html { redirect_to(@notification) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.xml
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.xml  { head :ok }
    end
  end

	def confirm
		# Parameters: {"AccountSid"=>"AC6524b76ade95cfec0c693cc0c53b7176",
		# "From"=>"+18122141761", "SmsStatus"=>"sent", "To"=>"+18123500093",
		# "SmsSid"=>"SM1326520726dbe9f42761c93239f25639", "ApiVersion"=>"2010-04-01"}
		if params['SmsStatus'] == 'sent'
			notification = Notification.find_by_uid(params['SmsSid'])
			notification.confirm! unless notification.nil?
		end
	end

  def search

  end

  def results
    @query = "SELECT * FROM notifications"
    unless params[:notification][:sender] == ""
      if @query == "SELECT * FROM notifications"
        @query += " WHERE"
      else
        @query += " AND"
      end
      @query += " sender LIKE '%" +
        params[:notification][:sender].gsub(/'/, "''") + "%'"
    end
    unless params[:notification][:recipients] == ""
      if @query == "SELECT * FROM notifications"
        @query += " WHERE"
      else
        @query += " AND"
      end
      @query += " recipient LIKE '%" +
        params[:notification][:recipients].gsub(/'/, "''") + "%'"
    end
    unless params[:notification][:subject] == ""
      if @query == "SELECT * FROM notifications"
        @query += " WHERE"
      else
        @query += " AND"
      end
      @query += " subject LIKE '%" +
        params[:notification][:subject].gsub(/'/, "''") + "%'"
    end
    unless params[:notification][:body] == ""
      if @query == "SELECT * FROM notifications"
        @query += " WHERE"
      else
        @query += " AND"
      end
      @query += " body LIKE '%" +
        params[:notification][:body].gsub(/'/, "''") + "%'"
    end
    unless params[:notification][:keywords] == ""
      if @query == "SELECT * FROM notifications"
        @query += " WHERE"
      else
        @query += " AND"
      end
      @query += " keywords LIKE '%" +
        params[:notification][:keywords].gsub(/'/, "''") + "%'"
    end
    unless params[:notification][:state] == ""
      if @query == "SELECT * FROM notifications"
        @query += " WHERE"
      else
        @query += " AND"
      end
      @query += " state = '" +
        params[:notification][:state].gsub(/'/, "''") + "'"
    end
    @query += " ORDER BY created_at DESC LIMIT 250"
    @notifications = Notification.find_by_sql(@query)
  end

  def voice
    @message = params[:message]
    render :layout => false
  end

end
