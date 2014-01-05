@Games = new Meteor.Collection "games"
@Players = new Meteor.Collection "players"
@PlotData = new Meteor.Collection "plotData"

# Permissions
@Games.allow(
	insert: () ->
		return true
	)

@Players.allow(
	insert: () ->
		return true
	remove: () ->
		return true
	)
