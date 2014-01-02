@Scores = new Meteor.Collection "scores"

# Permissions
@Scores.allow(
	insert: () ->
		return true
	)

# @MostRecentGifs.allow(
# 	update: () ->
# 		return true
# 	remove: () ->
# 		return true
# 	insert: () ->
# 		return true
# 	)