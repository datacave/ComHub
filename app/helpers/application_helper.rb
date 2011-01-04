# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def colorize(state)
		case state
			when "received"
				"yellow"
			when "throttled"
				"orange"
			when "suppressed"
				"red"
			when "addressed"
				"blue"
			when "apportioned"
				"green"
			when "created"
				"yellow"
			when "sent"
				"orange"
			when "delivered"
				"green"
			when "confirmed"
				"blue"
			when "acknowledged"
				"purple"
		end
	end

end
