@Games = new Meteor.Collection "games"
@Players = new Meteor.Collection "players"

# Permissions
@Games.allow(
	insert: () ->
		return true
	)

@Players.allow(
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

