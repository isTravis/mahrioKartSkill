Meteor.publish "scoresPub", ->
    Scores.find()
    trueskill = Meteor.require "trueskill"


    alice = {}
    alice.skill = [25.0, 25.0/3.0]

    bob = {}
    bob.skill = [25.0, 25.0/3.0]

    chris = {}
    chris.skill = [25.0, 25.0/3.0]

    darren = {}
    darren.skill = [25.0, 25.0/3.0]

    # // The four players play a game.  Alice wins, Bob and Chris tie for
    # // second, Darren comes in last.  The actual numerical values of the
    # // ranks don't matter, they could be (1, 2, 2, 4) or (1, 2, 2, 3) or
    # // (23, 45, 45, 67).  All that matters is that a smaller rank beats a
    # // larger one, and equal ranks indicate draws.

    alice.rank = 1
    bob.rank = 2
    chris.rank = 2
    darren.rank = 4

    trueskill.AdjustPlayers [alice, bob, chris, darren]

    # // Print the results.

    console.log "alice:"
    console.log alice.skill
    console.log "bob:"
    console.log bob.skill
    console.log "chris:"
    console.log chris.skill
    console.log "darren:"
    console.log darren.skill



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
