module ContactsHelper

	def add_channel_link(name)
		link_to_function name do |page|
			page.insert_html :top, :channels, :partial => 'channel', :object => Channel.new
		end
	end

	def add_pattern_link(name)
		link_to_function name do |page|
			page.insert_html :top, :patterns, :partial => 'pattern', :object => Pattern.new
		end
	end

end
