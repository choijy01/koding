AccountMixin = do ->
  init:(api)->
    {JAccount, JGuest} = api

    JAccount::tellKite = do->
      {Scrubber, Store} = Bongo.dnodeProtocol

      localStore = new Store
      remoteStore = new Store

      listenerId = 0

      channels = {}
      namesCache = {}

      scrub =(method, args, callback) ->
        scrubber = new Scrubber localStore
        scrubber.scrub args, =>
          scrubbed = scrubber.toDnodeProtocol()
          scrubbed.method or= method
          callback scrubbed

      request =(kiteName, method, args)->
        scrub method, args, (scrubbed) ->
          fetchChannel kiteName, (channel)->
            messageString = JSON.stringify(scrubbed)
            channel.publish messageString

      response =(kiteName, method, args) ->
        scrub method, args, (scrubbed) ->
          fetchChannel kiteName, (channel)=>
            channel.publish JSON.stringify(scrubbed)

      readyChannels = {}

      onReady = (channel, callback)->
        {name} = channel
        if readyChannels[name] then callback()
        else
          channel.once 'ready', ->
            readyChannels[name] ?= channel
            callback()

      ready =(resourceName)->
        @exchange = resourceName
        console.log "ready"
        @emit "ready"

      error =(err)->
        cycleChannel.call this
        console.error err

      ping = (callback) ->
        @publish JSON.stringify(
          method      : 'ping'
          arguments   : []
          callbacks   : {}
        )
        @once 'pong', ->
          callback()  if callback

      pong = ->
        @emit 'pong'
        @lastPong = Date.now()

      cycleChannel =->
        @off()
        @stopPinging?()
        delete channels[@name]
        delete namesCache[@authenticationInfo.name]

        kite = KD.getSingleton "kiteController"
        kite.deleteKite(@name)

      messageArrived = (msg) ->
        console.log msg

        clearTimeout @unresponsiveTimeout
        @unresponded = 0

        @pingTimeout = setTimeout =>
          @ping()
        , 5000

      messageSent = (msg) ->
        console.log msg

        clearTimeout @pingTimeout
        clearTimeout @unresponsiveTimeout

        @unresponsiveTimeout = setTimeout =>
          @emit "possibleUnresponsive"
        , 5000

      possibleUnresponsive = ->
        @unresponded ||= 0
        @unresponded  += 1

        if @unresponded > 1
          @emit 'unresponsive'

      unresponsive = -> cycleChannel.bind this

      messageHandler =(kiteName, args) ->
        {method} = args
        callback =
          if method is 'ready'
            ready.bind this
          else if method is 'error'
            error.bind this
          else if method is 'pong'
            pong.bind this
          else if method is 'cycleChannel'
            cycleChannel.bind this
          else
            callback = localStore.get(args.method) ? ->
        scrubber = new Scrubber localStore
        unscrubbed = scrubber.unscrub args, (callbackId)->
          unless remoteStore.has callbackId
            remoteStore.add callbackId, ->
              response kiteName, callbackId, [].slice.call(arguments)
          remoteStore.get callbackId
        callback.apply this, unscrubbed

      getChannelName =(kiteName)->
        return namesCache[kiteName]  if namesCache[kiteName]
        delegate  = KD.whoami()
        nickname  = delegate?.profile.nickname ?
                    if delegate.guestId then "guest#{delegate.guestId}" ?
                    'unknown'
        channelName = "#{Bongo.createId 128}.#{nickname}.#{kiteName}"
        namesCache[kiteName] = channelName
        return channelName

      fetchChannel =(kiteName, callback)->
        channelName = getChannelName "kite-#{kiteName}"
        return callback readyChannels[channelName]  if readyChannels[channelName]
        channel = KD.remote.mq.subscribe channelName
        kiteController = KD.getSingleton 'kiteController'
        kiteController.addKite(kiteName, channel)

        unless channels[channelName]?
          channel.cycleChannel = -> cycleChannel.call this
          channel.ping = (callback) -> ping.call this, callback

          channel.on "message", messageHandler.bind channel, kiteName
          channel.on "publish", messageSent.bind channel
          channel.on "message", messageArrived.bind channel
          channel.on "possibleUnresponsive", possibleUnresponsive.bind channel
          channel.on "unresponsive", unresponsive.bind channel

          channel.once 'broker.subscribed', ->
            onReady channel, ->
              callback channel

        channels[channelName] = channel
        channel.setAuthenticationInfo
          serviceType : 'kite'
          name        : "kite-#{kiteName}"
          clientId    : KD.remote.getSessionToken()


      tellKite =(options, callback=->)->
        scrubber = new Scrubber localStore
        args = [options, callback]
        {method, kiteName} = options
        request kiteName, method, args
