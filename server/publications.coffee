Meteor.publish "gamesPub", -> 
    Games.find()

Meteor.publish "playersPub", (result) ->
    # games = Games.find().fetch()
    # playersDB = Players.find().fetch()

    # console.log "Beginning Side loop"
    # alice = {}
    # alice.skill = [31.337, 6.238]

    # bob = {}
    # bob.skill = [24.993, 5.434]

    # chris = {}
    # chris.skill = [18.664,   6.238]

    # darren = {}
    # darren.skill = [25.007,  5.434]

    # alice.rank = "1"
    # bob.rank = "2"
    # chris.rank = "3"
    # darren.rank = "4"

    
    # trueskill = Meteor.require("trueskill");

    # for i in [1..100]
    #     trueskill.AdjustPlayers([alice, bob, chris, darren]);

    #     console.log "Game " + i
    #     console.log("alice: " + alice.skill);
    #     console.log("bob: " + bob.skill);
    #     console.log("chris: " + chris.skill);
    #     console.log("darren: " + darren.skill);

    # console.log("End Side loop")

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
            
        # console.log players
        trueskill.AdjustPlayers players  
        # console.log players

        # Update the entry
        for i in [0..result.ranks.length-1]
            name = result.ranks[i].name
            x = Players.findOne({name:name})
            
            x.currentMu = players[i].skill[0]
            x.currentSigma = players[i].skill[1]
            x.muHistory.push(players[i].skill[0])
            x.sigmaHistory.push(players[i].skill[1])
            x.gamesPlayed += 1

            Players.update({name:name}, x)




    Players.find({}, { sort: { 'name': 1 }})

    # console.log "finished"

    # allPlayers = {}


    # x = {}
    # x.skill = [25.0, 25.0/3.0]
    # x.rank = 1

    # allPlayers[0] = x

    # x = {}
    # x.skill = [25.0, 25.0/3.0]
    # x.rank = 2

    # allPlayers[1] = x

    # x = {}
    # x.skill = [25.0, 25.0/3.0]
    # x.rank = 3

    # allPlayers[2] = x

    # x = {}
    # x.skill = [25.0, 25.0/3.0]
    # x.rank = 4

    # allPlayers[3] = x


    # players = [allPlayers[0],allPlayers[1],allPlayers[2],allPlayers[3]]

    # trueskill.AdjustPlayers players

    # console.log players[0].skill
    # console.log players[1].skill
    # console.log players[2].skill
    # console.log allPlayers[1].skill
    # console.log allPlayers[2].skill
    # console.log allPlayers[3].skill
    # alice = {}
    # alice.skill = [25.0, 25.0/3.0]

    # bob = {}
    # bob.skill = [25.0, 25.0/3.0]

    # chris = {}
    # chris.skill = [25.0, 25.0/3.0]

    # darren = {}
    # darren.skill = [25.0, 25.0/3.0]

    # # // The four players play a game.  Alice wins, Bob and Chris tie for
    # # // second, Darren comes in last.  The actual numerical values of the
    # # // ranks don't matter, they could be (1, 2, 2, 4) or (1, 2, 2, 3) or
    # # // (23, 45, 45, 67).  All that matters is that a smaller rank beats a
    # # // larger one, and equal ranks indicate draws.

    # alice.rank = 1
    # bob.rank = 2
    # chris.rank = 2
    # darren.rank = 4

    # trueskill.AdjustPlayers [alice, bob, chris, darren]

    # // Print the results.

    # console.log "alice:"
    # console.log alice.skill
    # console.log "bob:"
    # console.log bob.skill
    # console.log "chris:"
    # console.log chris.skill
    # console.log "darren:"
    # console.log darren.skill



# Meteor.publish "mostRecentGifsPub", (numGifs) ->
#     sub = this
#     collectionName = "mostRecentGifs"

#     gifCount = Gifs.find().count()
#     if numGifs == 0
#         #return all
#         for i in [gifCount-1..0]
#             gif = Gifs.findOne({intID: i})
#             sub.added collectionName, gif._id, gif
#     else
#         #return numGifs
#         for i in [gifCount-1..gifCount-numGifs]
#             gif = Gifs.findOne({intID: i})
#             sub.added collectionName, gif._id, gif

#     sub.ready()
#     return



# Scores{
#     Jasmin:
#         current mu 
#         current sigma
#         mu history
#         sigma history



#     Steve:


# }

# Games{
#     game 
#         game.data
#         game.result (object)
# }


# When there is a new game
# load the current score for all the associated players
# load the game scores
# calculate the new ranks
# update the player scores history and the current scores
