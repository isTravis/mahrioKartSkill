# Template.main.events = 
#     "click div.announcement-content": (d) ->
#         killAnnouncement()

Template.scores.created = ->
    console.log "created"
    # trueskill = Npm.require 'trueskill'
    # trueskill = Meteor.require('trueskill')

# Votes.insert({msg: "hello"});
# Votes.insert(
#         metric: Session.get "metric"
#         left: Session.get "left"
#         right: Session.get "right"
#         choice: choice
#         time: clickTime
#         decisionTime: decisionTime
#         ip: Session.get "ip"
#         city: Session.get "city"
#         region: Session.get "region"
#         country: Session.get "country"
#     )