module KeywordsHelper

	def render_keywords(keyword, markup = "")
		
		if keyword.children_count > 0
			markup += "<li id='" + simplify(keyword.designation) + "'>\n"
			markup += "<span class='handle'></span>\n"
			markup += "<a>" + keyword.designation + "</a>\n"
			keyword.direct_children.each do |k|
				markup += "<ul>\n"
				markup = render_keywords(k, markup)
				markup += "</ul>\n"
			end
		else
			markup += "<li id='" + simplify(keyword.designation) + "' class='file'>"
			markup += "<a>" + keyword.designation + "</a>"
		end
		markup += "</li>\n"
		return markup
	end

	def simplify(word)
		word.downcase.gsub(/[ _-]/, "")
	end

end
