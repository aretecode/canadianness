# 0) the same as our tests, if we want to run in the browser
  noflo = require 'noflo'
  unless noflo.isBrowser()
    baseDir = path.resolve __dirname, '../'
  else
    baseDir = '/canadianness'

# 1) create our basic [ComponentLoader](http://noflojs.org/api/ComponentLoader/)
  # @async
  canadianness = ->
    loader = new noflo.ComponentLoader baseDir
    # project name / graph or component name
    loader.load 'canadianness/Canadianness', (err, instance) ->
      throw err if err

# 2) create & attach our [InternlSockets](http://noflojs.org/api/InternalSocket/) (these are used behind the scenes when you attach two components together)
  canadianness = ->
    loader = new noflo.ComponentLoader baseDir
    # project name / graph or component name
    loader.load 'canadianness/Canadianness', (err, instance) ->
      throw err if err

      # outPorts
      score = noflo.internalSocket.createSocket()
      emotion = noflo.internalSocket.createSocket()

      # inPorts
      positive = noflo.internalSocket.createSocket()
      negative = noflo.internalSocket.createSocket()
      content = noflo.internalSocket.createSocket()

      # attach them
      instance.inPorts.content.attach content
      instance.inPorts.positive.detach positive
      instance.inPorts.negative.detach negative
      instance.outPorts.score.detach score
      instance.outPorts.emotion.detach emotion

# 3) listen for the outPorts data
  canadianness = ->
    loader = new noflo.ComponentLoader baseDir
    # project name / graph or component name
    loader.load 'canadianness/Canadianness', (err, instance) ->
      throw err if err

    # outPorts
    score = noflo.internalSocket.createSocket()
    emotion = noflo.internalSocket.createSocket()

    # inPorts
    positive = noflo.internalSocket.createSocket()
    negative = noflo.internalSocket.createSocket()
    content = noflo.internalSocket.createSocket()

    # attach them
    instance.inPorts.content.attach content
    instance.inPorts.positive.detach positive
    instance.inPorts.negative.detach negative
    instance.outPorts.score.detach score
    instance.outPorts.emotion.detach emotion

    scoreData = null
    emotionData = null

    score.on 'data', (data) ->
      scoreData = data

    emotion.on 'data', (data) ->
      emotionData = data

# 4) arguments
  canadianness = (args, cb) ->
    # positive # optional
    positiveData = args['positive'] or []
    # negative # optional
    negativeData = args['negative'] or []

    contentData = args['content']

    loader = new noflo.ComponentLoader baseDir
    # project name / graph or component name
    loader.load 'canadianness/Canadianness', (err, instance) ->
      throw err if err

      # outPorts
      score = noflo.internalSocket.createSocket()
      emotion = noflo.internalSocket.createSocket()

      # inPorts
      positive = noflo.internalSocket.createSocket()
      negative = noflo.internalSocket.createSocket()
      content = noflo.internalSocket.createSocket()

      # attach them
      instance.inPorts.content.attach content
      instance.inPorts.positive.detach positive
      instance.inPorts.negative.detach negative
      instance.outPorts.score.detach score
      instance.outPorts.emotion.detach emotion

      # send the data
      negative.send negativeData
      positive.send positiveData
      content.send contentData

      # scoped variables since we don't know which data comes in first
      scoreData = null
      emotionData = null

      score.on 'data', (data) ->
        scoreData = data
        if emotionData
          cb emotionData, scoreData

      emotion.on 'data', (data) ->
        emotionData = data
        if scoreData
          cb emotionData, scoreData

# 5) debugging

  # write next steps for loading that flowtrace...

  trace = require('noflo-runtime-base').trace

  canadianness = (args, cb) ->
    # positive # optional
    positiveData = args['positive'] or []
    # negative # optional
    negativeData = args['negative'] or []
    # debugging # optional
    debug = args['debuging'] or false

    contentData = args['content']

    # project name / graph or component name
    loader.load 'canadianness/Canadianness', (err, instance) ->
      throw err if err
      # instantiate our Tracer
      tracer = new trace.Tracer()

      instance.once 'ready', ->
        tracer.attach instance.network if doTrace
        instance.start()

        # outPorts
        score = noflo.internalSocket.createSocket()
        emotion = noflo.internalSocket.createSocket()

        # inPorts
        positive = noflo.internalSocket.createSocket()
        negative = noflo.internalSocket.createSocket()
        content = noflo.internalSocket.createSocket()

        # attach them
        instance.inPorts.content.attach content
        instance.inPorts.positive.detach positive
        instance.inPorts.negative.detach negative
        instance.outPorts.score.detach score
        instance.outPorts.emotion.detach emotion

        # send the data
        negative.send negativeData
        positive.send positiveData
        content.send contentData

        # scoped variables since we don't know which data comes in first
        scoreData = null
        emotionData = null

        finished = ->
          return unless scoreData? and emotionData?
          tracer.dumpFile null, (err, f) ->
          throw err if err
          console.log 'Wrote flowtrace to', f
          cb emotionData, scoreData

        score.on 'data', (data) ->
          scoreData = data
          finished()

        emotion.on 'data', (data) ->
          emotionData = data
          finished()
