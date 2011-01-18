# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def colorize(state)
		case state
			when "received"
				"#f9e21e" # yellow
			when "throttled"
				"#fc7b11" # orange
			when "suppressed"
				"#c41010" # red
			when "addressed"
				"#3967b0" # blue
			when "apportioned"
				"#11a20e" # green
			when "created"
				"#f9e21e" # yellow
			when "sent"
				"#fc7b11" # orange
			when "delivered"
				"#11a20e" # green
			when "confirmed"
				"#3967b0" # blue
			when "acknowledged"
				"#671f97" # purple
		end
	end

end
