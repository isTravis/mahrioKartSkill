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
	makePlot()

# Template.players.scores = ->
	# return 5

# while counter < 500{
# 	fakeGame();
# 	counter +=1;
# }

# @fakeGame = () ->
# 	ranks = [{name:"Travis", rank: "2"},{name:"Jasmin", rank: "3"},{name:"Maisam", rank: "4"},{name:"Steve", rank: "1"}]
# 	numValues = 4
# 	names = ["Travis","Jasmin","Maisam","Steve"]
# 	places = [1,2,3,4]
# 	gameTime = new Date().getTime()

# 	gameResult = 
# 		timestamp: gameTime
# 		ranks: ranks

# 	if numValues > 1 and numValues < 5
# 		Session.set "newGameResult", gameResult

# 		Games.insert(
# 			date: gameTime
# 			numPlayers: numValues
# 			names: names
# 			ranks: places
# 		)
# 		makePlot()


Template.players.events = 
	"click div.submitGame": (d) ->
		srcE = if d.srcElement then d.srcElement else d.target
		console.log srcE
		x = $(srcE).parent().children(".players").children(".player")
		
		numValues = 0
		ranks = []
		names = []
		places = []
		gameTime = new Date().getTime()
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
				date: gameTime
				numPlayers: numValues
				names: names
				ranks: places
			)
			makePlot()
		else
			console.log "Between two and four players"

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
		currentMu: 25
		currentSigma: 25/3
		muHistory: [25]
		sigmaHistory: [25/3]
		gamesPlayed: 0
	)

@makePlot = () ->
	plottedPlayers = Session.get "plottedPlayers"
	
	plots = []

	for i in [0..plottedPlayers.length-1]
		# console.log plottedPlayers[i]
		# console.log Players.findOne({name:plottedPlayers[i]})
		thisPlayer = Players.findOne({name:plottedPlayers[i]})
		if thisPlayer
			# console.log thisPlayer
			mu = thisPlayer.currentMu
			sigma = thisPlayer.currentSigma
			plots.push({label:thisPlayer.name, data:createGaussian(mu, sigma, 100)})

	$.plot "#placeholder", 
		plots,
		lines:
		    show: true
		    fill: true
	    height: '200px'
	    
@makeScoreTables = () ->
	if $(".scoreTable").children("tbody").children(".player-row").length
		$(".scoreTable").dataTable
			bPaginate: false
			bLengthChange: false
			bFilter: false
			bSort: true
			bInfo: false		
			bAutoWidth: false
		console.log $(".scoreTable").children("tbody").children(".player-row").length

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