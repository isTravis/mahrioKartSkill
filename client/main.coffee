Template.players.players = ->
	Players.find().fetch()
	
Template.players.created = ->
	# Create variable containing the names that will be plotted by default
	Session.set "plottedPlayers", ["Travis","Steve","Maisam","Jasmin"]

Template.players.rendered = ->
	# Set the newGameResult to 0, both initiating it and toggling it back to 0 after a result has been posted
	Session.set "newGameResult", 0
	
	# Get the player names to plot, set toggle-box colors, and plot graphs
	plottedPlayers = Session.get "plottedPlayers"
	for i in [0..plottedPlayers.length-1]
		$(".toggle-boxes").children("." + (plottedPlayers[i])).addClass("highlighted")
	makePlot()

	# Set the slider axis-max and update label
	numGames = PlotData.find().fetch()[PlotData.find().count()-1].gameNum
	$(".plotRange").prop('max',numGames)
	$(".plotVal").html("Game " + numGames)

Template.players.events = 
	# When fixedAxes is clicked, set variable fix plot axes. Update css classes
	"click .fixedAxes": (d) ->
		srcE = if d.srcElement then d.srcElement else d.target
		if $(srcE).hasClass("highlighted")
			$(srcE).removeClass("highlighted")
			Session.set "fixedAxes", false
			makePlot()
		else
			$(srcE).addClass("highlighted")
			Session.set "fixedAxes", true
			makePlot()

	# When slider is dragged, update plot graphs
	"change .plotRange": (d)->
		newVal = $(".plotRange").attr("value") 
		Session.set "plotGameNum", newVal
		$(".plotVal").html("Game " + newVal)
		makePlot()

	# When scores are submitted, package the values, insert game, and go.
	"click div.submitGame": (d) ->
		srcE = if d.srcElement then d.srcElement else d.target
		x = $(srcE).parent().children(".players").children(".player")
		
		numValues = 0
		ranks = []
		names = []
		places = []
		gameTime = new Date().getTime()
		gameDate = String(new Date(gameTime)).split(" GMT")[0]

		# For each value box, get the values and package them in object
		for i in [0..x.length-1]
			name = $(x[i]).children("h2").html()
			val = $(x[i]).children("input").val()
			# But first, check to make sure the value box contains a value
			if val
				numValues += 1
				ranks.push({name:name, rank:val})
				names.push(name)
				places.push(val)

		gameResult = 
			timestamp: gameTime
			ranks: ranks

		# Check to ensure that games contain 2, 3, or 4 players
		if numValues > 1 and numValues < 5
			# Set gameResult value. This will trigger the publication to update Players collection
			Session.set "newGameResult", gameResult

			Games.insert(
				timeStamp: gameTime
				gameDate: gameDate
				numPlayers: numValues
				names: names
				ranks: places
			)

			# Update slider values and draw new graphs.
			newPlotVal = $(".plotRange").attr('max') + 1
			Session.set "plotGameNum", 0
			makePlot()
		else 
			alert "Can only enter 2, 3, or 4 players per Grand Prix"

	# If a toggle name is clicked, add or remove it from the Session variable and re-draw the plot
	"click div.toggleBox": (d) ->
		srcE = if d.srcElement then d.srcElement else d.target
		plottedPlayers = Session.get "plottedPlayers"
		if $(srcE).hasClass("highlighted")
			$(srcE).removeClass("highlighted")
			index = plottedPlayers.indexOf($(srcE).html())
			if index > -1
			    plottedPlayers.splice(index, 1)
			Session.set "plottedPlayers", plottedPlayers
			makePlot()
		else
			$(srcE).addClass("highlighted")
			plottedPlayers.push($(srcE).html())
			Session.set "plottedPlayers", plottedPlayers
			makePlot()
		

Template.scores.scores = ->
	Players.find().fetch()

Template.scores.rendered = ->
	makeScoreTables() # Call function to generate DataTable
	
	# Get all the columns designated as two-decimal and fix their decimal place. Apparently not always - 2. Doh, fix that.
	x = $(".two-decimal") 
	for i in [0..x.length-1]
		x[i].innerText = parseFloat(x[i].innerText).toFixed(3)

Template.games.games = ->
	Games.find().fetch()


# Generate a new player with blank stats
@newPlayer = (playername) ->
	playerName = playername
	Players.insert(
		name: playerName
		currentLevel: 0
		currentMu: 25
		currentSigma: 25/3
		levelHistory: [0]
		muHistory: [25]
		sigmaHistory: [25/3]
		gamesPlayed: 0
		championshipsPlayed: 0
		championshipsWon: 0
		percentChampion: 0
	)

#Remove a player
@removePlayer = (playerName) ->
	removeID = Players.findOne({name:playerName})._id
	console.log removeID
	Players.remove(removeID)

# Draw the all graphs
@makePlot = () ->
	plottedPlayers = Session.get "plottedPlayers" # Players to plot
	gameNum = Session.get "plotGameNum" # Plot the results after N games

	if gameNum # If gameNum has been set, render that plot
		plotData = PlotData.findOne({gameNum:parseInt(gameNum)})
		plots = []
		for i in [0..plottedPlayers.length-1]
			name = plottedPlayers[i]
			mu = plotData.mus[name]
			sigma = plotData.sigmas[name]
			plots.push({label:name, data:createGaussian(mu, sigma, 100)})
	else # Else, render the most recent plot.
		plots = []
		for i in [0..plottedPlayers.length-1]
			thisPlayer = Players.findOne({name:plottedPlayers[i]})
			if thisPlayer
				mu = thisPlayer.currentMu
				sigma = thisPlayer.currentSigma
				plots.push({label:thisPlayer.name, data:createGaussian(mu, sigma, 100)})
	
	# Check if the axes should be fixed or not, and then call the associated plot function
	fixedAxes = Session.get "fixedAxes"
	if fixedAxes
		$.plot "#placeholder", 
			plots,
			lines:
			    show: true
			    fill: true
		    xaxis:
	            min: 0 
	            max: 50  
	            tickSize: 5
	        yaxis:
	            min:0 
	            max: 0.35  
	            tickSize: 0.1
	else            
		$.plot "#placeholder", 
			plots,
			lines:
			    show: true
			    fill: true
            
# Generate the Scores DataTable	    
@makeScoreTables = () ->
	if $(".scoreTable").children("tbody").children(".player-row").length
		$(".scoreTable").dataTable
			bPaginate: false
			bLengthChange: false
			bFilter: false
			bSort: true
			bInfo: false		
			bAutoWidth: false
		# console.log $(".scoreTable").children("tbody").children(".player-row").length

		$('.sparkline').sparkline "html",
		type: "line"
		lineColor: "#00bfff"
		fillColor: "#00bfff"
		chartRangeMin: 0
		chartRangeMax: 1.0
		spotColor: ""
		minSpotColor: ""
		maxSpotColor: ""
		width:"200px"

# Generate the points for a Gaussian plot
@createGaussian = (mu, sigma, numPoints) ->
	pointArray = []
	for i in [(mu-5*sigma)..(mu+5*sigma)] by 5*sigma/numPoints*2
		x = i
		y = (1 / Math.sqrt(2*Math.PI*Math.pow(sigma,2))) * Math.exp(-1 * Math.pow((x-mu), 2) / (2 * Math.pow(sigma,2)));
		pointArray.push [x,y]
	return pointArray
