module CandidatesHelper
	def link_to_path(name, id)
		link_to name || '', "/somsri#/candidate/#{id}"
	end	
	
end