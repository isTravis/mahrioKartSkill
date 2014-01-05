# Template.main.events = 
#     "click div.announcement-content": (d) ->
#         killAnnouncement()

Template.players.players = ->
	Players.find().fetch()
	
Template.players.created = ->
	Session.set "plottedPlayers", ["Travis","Steve","Maisam","Jasmin"]

	

Template.players.rendered = ->
	Session.set "newGameResult", 0
	# makeScoreTables()
	plottedPlayers = Session.get "plottedPlayers"
	for i in [0..plottedPlayers.length-1]
		$(".toggle-boxes").children("." + (plottedPlayers[i])).addClass("highlighted")
	makePlot()


	numGames = PlotData.find().fetch()[PlotData.find().count()-1].gameNum
	$(".plotRange").prop('max',numGames)
	$(".plotVal").html("Game " + numGames)
	# console.log "max is " + $(".plotRange").attr('max')
	# console.log "count " + PlotData.find().count()

	# gameNum = Session.get "plotGameNum"
	# if gameNum
	# 	$(".plotRange").prop('value',gameNum)
	# else
	# 	$(".plotRange").prop('value',numGames)

Template.players.events = 

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

	"change .plotRange": (d)->
		newVal = $(".plotRange").attr("value")
		# console.log newVal
		Session.set "plotGameNum", newVal
		$(".plotVal").html("Game " + newVal)
		makePlot()

	"click div.submitGame": (d) ->
		srcE = if d.srcElement then d.srcElement else d.target
		console.log srcE
		x = $(srcE).parent().children(".players").children(".player")
		
		numValues = 0
		ranks = []
		names = []
		places = []
		gameTime = new Date().getTime()
		gameDate = String(new Date(gameTime)).split(" GMT")[0]
		for i in [0..x.length-1]
			name = $(x[i]).children("h2").html()
			val = $(x[i]).children("input").val()
			console.log val
			if val
				numValues += 1
				ranks.push({name:name, rank:val})
				names.push(name)
				places.push(val)
		# console.log ranks
		gameResult = 
			timestamp: gameTime
			ranks: ranks

		console.log numValues
		if numValues > 1 and numValues < 5
			Session.set "newGameResult", gameResult

			Games.insert(
				timeStamp: gameTime
				gameDate: gameDate
				numPlayers: numValues
				names: names
				ranks: places
			)
			newPlotVal = $(".plotRange").attr('max') + 1
			Session.set "plotGameNum", 0
			makePlot()
		else
			console.log "Between two and four players"


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
	makeScoreTables()
	x = $(".two-decimal")
	for i in [0..x.length-1]
		x[i].innerText = parseFloat(x[i].innerText).toFixed(3)

Template.games.games = ->
	Games.find().fetch()

# Template.games.rendered = ->
# 	x = $(".date-entry")
# 	for i in [0..x.length-1]
# 		unixStamp = parseFloat(x[i].innerText)
# 		date = new Date(unixStamp);
# 		x[i].innerText = date
		# $(".x").children("." + (plottedPlayers[i])).addClass("highlighted")
	# makePlot()
# Template.games.rendered = ->
# 	if $(".gameTable").children("tbody").children(".game-row").length
# 		$(".gameTable").dataTable
# 			bPaginate: false
# 			bLengthChange: false
# 			bFilter: false
# 			bSort: true
# 			bInfo: false		
# 			bAutoWidth: false


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
@removePlayer = (playerName) ->
	removeID = Players.findOne({name:playerName})._id
	console.log removeID
	Players.remove(removeID)

@makePlot = () ->

	plottedPlayers = Session.get "plottedPlayers"
	gameNum = Session.get "plotGameNum"

	if gameNum
		plotData = PlotData.findOne({gameNum:parseInt(gameNum)})
		plots = []
		for i in [0..plottedPlayers.length-1]
			name = plottedPlayers[i]
			mu = plotData.mus[name]
			sigma = plotData.sigmas[name]
			plots.push({label:name, data:createGaussian(mu, sigma, 100)})
	else
		plots = []
		for i in [0..plottedPlayers.length-1]
			thisPlayer = Players.findOne({name:plottedPlayers[i]})
			if thisPlayer
				mu = thisPlayer.currentMu
				sigma = thisPlayer.currentSigma
				plots.push({label:thisPlayer.name, data:createGaussian(mu, sigma, 100)})
	
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



@createGaussian = (mu, sigma, numPoints) ->
	pointArray = []
	for i in [(mu-5*sigma)..(mu+5*sigma)] by 5*sigma/numPoints*2
		x = i
		y = (1 / Math.sqrt(2*Math.PI*Math.pow(sigma,2))) * Math.exp(-1 * Math.pow((x-mu), 2) / (2 * Math.pow(sigma,2)));
		pointArray.push [x,y]
	return pointArray
