module CandidatesHelper
	def link_to_full_name(candidate)
		link_to candidate.full_name, "/scouts/#{candidate.id}"
	end	
end