Deps.autorun ->
    scoresSub = Meteor.subscribe "scoresPub"
    
  # # sub.stop() # Stop the previous subscription, because it's changed.
  # page = Session.get "page"
  
  # # Switch subscriptions based on the loaded page to avoid unneccsary load. Greatly increases speed of front page.
  # switch page
  #   when "main" 
  #       metricSub = Meteor.subscribe "metricPub"
  #       achievementsSub = Meteor.subscribe "achievementsPub"

  #       lastUpdate = Session.get "lastUpdate"
  #       votesSub = Meteor.subscribe "votesPub", lastUpdate
  #       twoGifsSub = Meteor.subscribe "twoGifsPub", lastUpdate

  #       metric = Session.get "metric"
  #       topBottomThreeSub = Meteor.subscribe "topBottomThreePub", metric

  #       votes = Session.get "localVoteCount"
  #       hours = Session.get "localHoursCount"
  #       days = Session.get "localDaysCount"
  #       weeks = Session.get "localWeeksCount"
  #       months = Session.get "localMonthsCount"
  #       #if votes and hours and days and weeks and months
  #       achievementsSub = Meteor.subscribe "achievementsPub", votes, hours, days, weeks, months

  #   when "results"
  #       metric = Session.get "currentMetric"
  #       sortBy = Session.get "sortBy"

  #       # topTenSub = Meteor.subscribe "topTenPub", metric
  #       resultSpectrumSub = Meteor.subscribe "resultSpectrumPub", sortBy
        
  #   when "search"
  #       metricSub = Meteor.subscribe "metricPub"

  #       searchVals = Session.get "searchVals"
  #       searchResultsSub = Meteor.subscribe "searchResultsPub", searchVals

  #   when "admin"
  #       numGifs = Session.get "numRecent"
  #       console.log numGifs
  #       mostRecentGifsSub = Meteor.subscribe "mostRecentGifsPub", numGifs

  #   when "gifProfile"
  #       scoresSub = Meteor.subscribe "scoresPub"

  #   else
  #       # console.log "else"
  #       return
