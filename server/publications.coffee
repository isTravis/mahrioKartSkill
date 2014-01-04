Meteor.publish "gamesPub", -> 
    Games.find({}, { sort: { 'timeStamp': -1 }})

Meteor.publish "playersPub", (result) ->
    if result
        trueskill = Meteor.require "trueskill"
        players = []
        playerScores = {}
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