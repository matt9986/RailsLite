module UrlHelper
	def method_missing(sym, *splat)
		string = sym.to_s
		return super unless string[-4..-1] == "_url"
		output = string[0..-5].gsub("_","/")
		splat.each{|item| output + "/#{item.id}"}
		"localhost:8080/"+output
	end

	def link_to(name, url)
		"<a href='#{url}'>#{name}</a>"
	end

	def button_to(name, url, method_hash)
		<<-HTML
		<form action='#{url}' method='post'>
			<input type='hidden' name='authenticity_token' value='#{form_authenticity_token}>'
			<input type='hidden' name='_method' value=#{method_hash[:method]}>
			<input type='submit' value='#{name}'>
		</form>
		HTML
	end
end