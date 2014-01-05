Meteor.publish "gamesPub", -> 
    Games.find({}, { sort: { 'timeStamp': -1 }})

Meteor.publish "plotDataPub", (gameNum) ->
    # PlotData.findOne({gameNum:gameNum})
    PlotData.find({}, { sort: { 'gameNum': 1 }})


Meteor.publish "playersPub", (result) ->
    if result
        trueskill = Meteor.require "trueskill"
        players = []
        # console.log result
        for i in [0..result.ranks.length-1]
            # For each player in the game, get their rank, append
            name = result.ranks[i].name
            thisTemp = Players.findOne({name:name})
            rank = result.ranks[i].rank
            currentMu = thisTemp.currentMu
            currentSigma = thisTemp.currentSigma

            tempPlayer = {}
            tempPlayer.skill = [currentMu,currentSigma]
            tempPlayer.rank = rank

            players[i] = tempPlayer

        trueskill.AdjustPlayers players  

        # Update the entry
        for i in [0..result.ranks.length-1]
            name = result.ranks[i].name
            x = Players.findOne({name:name})
            
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

        # gameNum = Games.find().count() + 1
        # # console.log "GameNum " + gameNum
        # plotData = {}
        # plotData.gameNum = gameNum
        # sigmas = {}
        # mus = {}
        # _.forEach Players.find().fetch(), (player) ->
        #     sigmas.player = player.
        #     players.push({name:player.name, mu:player.currentMu, sigma:player.currentSigma})
        # plotData.players = players

        # PlotData.insert(plotData)
        gameNum = Games.find().count() + 1
        # console.log "GameNum " + gameNum
        # plotData.gameNum = gameNum
        sigmas = {}
        mus = {}
        _.forEach Players.find().fetch(), (player) ->
            sigmas[player.name] = player.currentSigma
            mus[player.name] = player.currentMu

        PlotData.insert({gameNum:gameNum, sigmas:sigmas, mus:mus})


    Players.find({}, { sort: { 'name': 1 }})


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

    
Meteor.methods rerunHistory: () ->
    players = Players.find().fetch()
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
            # console.log tempPlayer

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

        # gameNum = i + 1
        # # console.log "GameNum " + gameNum
        # plotData = {}
        # plotData.gameNum = gameNum
        # players = []
        # _.forEach Players.find().fetch(), (player) ->
        #     players.push({name:player.name, mu:player.currentMu, sigma:player.currentSigma})
        # plotData.players = players

        # PlotData.insert(plotData)


        gameNum = i + 1
        # console.log "GameNum " + gameNum
        # plotData.gameNum = gameNum
        sigmas = {}
        mus = {}
        _.forEach Players.find().fetch(), (player) ->
            sigmas[player.name] = player.currentSigma
            mus[player.name] = player.currentMu

        PlotData.insert({gameNum:gameNum, sigmas:sigmas, mus:mus})



