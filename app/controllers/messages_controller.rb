class MessagesController < ApplicationController
	# GET /messages
	# GET /messages.xml
	def index
		#@messages = Message.all
		# See config/environment.rb
		@messages = Message.paginate :page => params[:page],
			:order => "created_at DESC", :per_page => 15
		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @messages }
		end
	end

	# GET /messages/1
	# GET /messages/1.xml
	def show
		@message = Message.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @message }
		end
	end

	# GET /messages/new
	# GET /messages/new.xml
	def new
		@message = Message.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @message }
		end
	end

	# GET /messages/1/edit
	def edit
		@message = Message.find(params[:id])
	end

	# POST /messages
	# POST /messages.xml
	def create
		@message = Message.new(params[:message])

		respond_to do |format|
			if @message.save
				flash[:notice] = 'Message was successfully created.'
				format.html { redirect_to(@message) }
				format.xml	{ render :xml => @message, :status => :created, :location => @message }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @message.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /messages/1
	# PUT /messages/1.xml
	def update
		@message = Message.find(params[:id])

		respond_to do |format|
			if @message.update_attributes(params[:message])
				flash[:notice] = 'Message was successfully updated.'
				format.html { redirect_to(@message) }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @message.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /messages/1
	# DELETE /messages/1.xml
	def destroy
		@message = Message.find(params[:id])
		@message.destroy

		respond_to do |format|
			format.html { redirect_to(messages_url) }
			format.xml	{ head :ok }
		end
	end


	def search

	end


	def results
		@query = "SELECT * FROM messages"
		unless params[:message][:sender] == ""
			if @query == "SELECT * FROM messages"
				@query += " WHERE"
			else
				@query += " AND"
			end
			@query += " sender LIKE '%" +
				params[:message][:sender].gsub(/'/, "''") + "%'"
		end
		unless params[:message][:recipients] == ""
			if @query == "SELECT * FROM messages"
				@query += " WHERE"
			else
				@query += " AND"
			end
			@query += " recipients_direct LIKE '%" +
				params[:message][:recipients].gsub(/'/, "''") + "%'"
		end
		unless params[:message][:subject] == ""
			if @query == "SELECT * FROM messages"
				@query += " WHERE"
			else
				@query += " AND"
			end
			@query += " subject LIKE '%" +
				params[:message][:subject].gsub(/'/, "''") + "%'"
		end
		unless params[:message][:body] == ""
			if @query == "SELECT * FROM messages"
				@query += " WHERE"
			else
				@query += " AND"
			end
			@query += " body LIKE '%" +
				params[:message][:body].gsub(/'/, "''") + "%'"
		end
		unless params[:message][:keywords] == ""
			if @query == "SELECT * FROM messages"
				@query += " WHERE"
			else
				@query += " AND"
			end
			@query += " keywords LIKE '%" +
				params[:message][:keywords].gsub(/'/, "''") + "%'"
		end
		unless params[:message][:state] == ""
			if @query == "SELECT * FROM messages"
				@query += " WHERE"
			else
				@query += " AND"
			end
			@query += " state = '" +
				params[:message][:state].gsub(/'/, "''") + "'"
		end
		@query += " ORDER BY created_at DESC LIMIT 250"
		@messages = Message.find_by_sql(@query)
	end
end
