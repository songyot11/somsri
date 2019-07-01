class VersionUtil

	def self.with_user(version)
		{
			id: version.id,
			item_type: version.item_type,
			event: version.event,
			object: version.object,
			object_changes: version.object_changes,
			created_at: version.created_at,
			user: User.find_by(id: version.whodunnit)
		}
	end
end