Meteor.publish "gamesPub", -> 
    Games.find({}, { sort: { 'timeStamp': -1 }})

Meteor.publish "plotDataPub", (gameNum) ->
    # PlotData.findOne({gameNum:gameNum})
    PlotData.find({}, { sort: { 'gameNum': 1 }})


Meteor.publish "playersPub", (result) ->
    # If a result has been published: update all the players. 
    if result
        trueskill = Meteor.require "trueskill"
        players = []

        # For each player in the game, get their rank, append
        for i in [0..result.ranks.length-1] # For each player submitted in the gameResult...
            name = result.ranks[i].name
            thisTemp = Players.findOne({name:name}) # Get the currently stored player data, to update it.
            rank = result.ranks[i].rank
            currentMu = thisTemp.currentMu
            currentSigma = thisTemp.currentSigma

            tempPlayer = {} # Create the data that will become the new Player's stats.
            tempPlayer.skill = [currentMu,currentSigma]
            tempPlayer.rank = rank

            players[i] = tempPlayer # Add the players past scores and newGame rank in order to run trueskill on it. 

        trueskill.AdjustPlayers players  

        # Update the entry with the results provided by AdjustPlayers
        for i in [0..result.ranks.length-1]
            name = result.ranks[i].name
            x = Players.findOne({name:name}) # Get the currently stored player data, to update it.
            
            x.currentLevel = parseFloat(players[i].skill[0]) - parseFloat(3*players[i].skill[1])
            x.currentMu = players[i].skill[0]
            x.currentSigma = players[i].skill[1]
            x.levelHistory.push(parseFloat(players[i].skill[0]) - parseFloat(3*players[i].skill[1]))
            x.muHistory.push(players[i].skill[0])
            x.sigmaHistory.push(players[i].skill[1])
            x.gamesPlayed += 1
            
            if isChampionship(result)
                x.championshipsPlayed +=1

                if result.ranks[i].rank == "1"
                    x.championshipsWon +=1
                x.percentChampion = (x.championshipsWon/x.championshipsPlayed)
            
            Players.update({name:name}, x)

        gameNum = Games.find().count() + 1
        sigmas = {}
        mus = {}
        _.forEach Players.find().fetch(), (player) ->
            sigmas[player.name] = player.currentSigma
            mus[player.name] = player.currentMu
        PlotData.insert({gameNum:gameNum, sigmas:sigmas, mus:mus})


    Players.find({}, { sort: { 'name': 1 }})

# Hard coded to define a championship as a game amongst the 4 roommates.
isChampionship = (result) ->
    hasMaisam = false
    hasSteve = false
    hasJasmin = false
    hasTravis = false
    for i in [0..result.ranks.length-1]
        name = result.ranks[i].name
        if name == "Travis"
            hasTravis = true
        else if name == "Jasmin"
            hasJasmin = true
        else if name == "Steve"
            hasSteve = true
        else if name == "Maisam"
            hasMaisam = true

    return hasMaisam and hasJasmin and hasTravis and hasSteve

# Used to allow a game to be deleted. Delete the game and then call this function to recalculate all the standings
# Implements the same procedure from the playersPub, but for each game in the history sequentially
Meteor.methods rerunHistory: () ->
    players = Players.find().fetch()

    # Clear all the plotData. Will re-enter at the end of this method.
    _.forEach PlotData.find().fetch(), (entry) ->
        console.log entry._id
        PlotData.remove(entry._id)    

    for i in [0..players.length-1]
        name = players[i].name

        thisPlayer = Players.findOne({name:name})
        thisPlayer.currentLevel = 0
        thisPlayer.currentSigma = 25/3
        thisPlayer.currentMu = 25
        thisPlayer.levelHistory = [0]
        thisPlayer.muHistory = [25]
        thisPlayer.sigmaHistory = [25/3]
        thisPlayer.gamesPlayed = 0
        thisPlayer.championshipsPlayed = 0
        thisPlayer.championshipsWon = 0
        thisPlayer.percentChampion = 0

        Players.update({name:name}, thisPlayer)


    games = Games.find({}, { sort: { 'timeStamp': 1 }}).fetch()
    for i in [0..games.length-1]
        games[i].timeStamp
        names = games[i].names
        ranks = games[i].ranks

        trueskill = Meteor.require "trueskill"
        players = []
        mimicRanks = []
        for j in [0..names.length-1]
            # For each name, add it and it's rank to players[] 
            # update entry
            name = names[j]
            thisTemp = Players.findOne({name:name})
            rank = parseFloat(ranks[j])
            mimicRanks.push({name:name, rank:rank})
            currentMu = (thisTemp.currentMu)
            currentSigma = (thisTemp.currentSigma)

            tempPlayer = {}
            tempPlayer.skill = [currentMu,currentSigma]
            tempPlayer.rank = rank

            players[j] = tempPlayer

        # Created as a dummy data so that we can pass it to isChampionship function
        mimicResult = 
            timestamp: 0
            ranks: mimicRanks

        trueskill.AdjustPlayers players  

        # Update the entry
        for j in [0..names.length-1]
            name = names[j]
            x = Players.findOne({name:name})
            
            x.currentLevel = parseFloat(players[j].skill[0]) - parseFloat(3*players[j].skill[1])
            x.currentMu = players[j].skill[0]
            x.currentSigma = players[j].skill[1]
            x.levelHistory.push(parseFloat(players[j].skill[0]) - parseFloat(3*players[j].skill[1]))
            x.muHistory.push(players[j].skill[0])
            x.sigmaHistory.push(players[j].skill[1])
            x.gamesPlayed += 1
            

            if isChampionship(mimicResult)
                x.championshipsPlayed +=1

                if ranks[j] == "1"
                    x.championshipsWon +=1
                x.percentChampion = (x.championshipsWon/x.championshipsPlayed)
            
            Players.update({name:name}, x)

        gameNum = i + 1

        sigmas = {}
        mus = {}
        _.forEach Players.find().fetch(), (player) ->
            sigmas[player.name] = player.currentSigma
            mus[player.name] = player.currentMu

        PlotData.insert({gameNum:gameNum, sigmas:sigmas, mus:mus})



