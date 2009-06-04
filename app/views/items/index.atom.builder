atom_feed do |feed|
	feed.title "My items list"
	feed.updated Time.now
	@current_objects.each do |task|
		feed.entry task do |entry|
			entry.title task.title
			entry.content( "Description : " + task.description + "<br /><br />" + render( :partial => "#{task.class.to_s.downcase.pluralize}/preview.html", :object =>task ), :type => 'html')
		end
	end
end
