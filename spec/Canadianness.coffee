noflo = require 'noflo'

# if you want to run your tests on the browser builds using phantom
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'canadianness'

# how we test the components first, then the graph as a whole
# because then we do not have to
# figure out where along the graph the problem is

describe.skip 'Canadianness graph', ->
  c = null
  content = null
  positive = null
  negative = null
  emotion = null
  score = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/Canadianness', (err, instance) ->
      return done err if err
      c = instance
      content = noflo.internalSocket.createSocket()
      positive = noflo.internalSocket.createSocket()
      negative = noflo.internalSocket.createSocket()
      c.inPorts.content.attach content
      c.inPorts.positive.attach positive
      c.inPorts.negative.attach negative
      done()
  beforeEach ->
    emotion = noflo.internalSocket.createSocket()
    score = noflo.internalSocket.createSocket()
    c.outPorts.emotion.attach emotion
    c.outPorts.score.attach score
  afterEach ->
    c.outPorts.emotion.detach emotion
    c.outPorts.score.detach score

  describe 'with content eh', ->
    it 'should be neutral, yet highly Canadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql 11
        done()

      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'neutral'
        done()

      negative.send ['']
      positive.send ['']
      content.send 'eh'

  describe 'content "A bunch of centers had a color cancelation."', ->
    it 'should be neutral, and uncanadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql -1
        done()

      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'neutral'
        done()

      negative.send ['']
      positive.send ['']
      content.send 'A bunch of centers had a color cancelation.'

describe.skip 'WordScore component', ->
  c = null
  content = null
  positive = null
  negative = null
  score = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/Canadianness', (err, instance) ->
      return done err if err
      c = instance
      content = noflo.internalSocket.createSocket()
      positive = noflo.internalSocket.createSocket()
      negative = noflo.internalSocket.createSocket()
      c.inPorts.content.attach content
      done()
  beforeEach ->
    emotion = noflo.internalSocket.createSocket()
    score = noflo.internalSocket.createSocket()
    c.outPorts.emotion.attach emotion
    c.outPorts.score.attach score
  afterEach ->
    c.outPorts.emotion.detach emotion
    c.outPorts.score.detach score

  describe 'with content eh', ->
    it 'should be neutral, yet highly Canadian', (done) ->
      score.on 'data', (data) ->
        chai.expect(data).to.eql 11
        done()

      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'neutral'
        done()

      negative.send ['']
      positive.send ['']
      content.send 'eh'

describe 'FindWords component', ->
  c = null
  word = null
  surrounding = null
  content = null
  matches = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/FindWords', (err, instance) ->
      return done err if err
      c = instance
      word = noflo.internalSocket.createSocket()
      content = noflo.internalSocket.createSocket()
      surrounding = noflo.internalSocket.createSocket()
      c.inPorts.word.attach word
      c.inPorts.content.attach content
      c.inPorts.surrounding.attach surrounding
      done()
  beforeEach ->
    matches = noflo.internalSocket.createSocket()
    c.outPorts.matches.attach matches
  afterEach ->
    c.outPorts.matches.detach matches

  describe 'with content eh', ->
    it 'should be find one `eh`', (done) ->
      matches.on 'data', (data) ->
        chai.expect(data).to.eql 'eh'
        done()

      word.send 'eh'
      surrounding.send false
      content.send 'eh'

  describe 'with content that has no `eh`s', ->
    it 'should send an empty array', (done) ->
      matches.on 'data', (data) ->
        chai.expect(data).to.eql []
        done()
      word.send 'eh'
      surrounding.send false
      content.send 'A string without it is a sad string.'

  describe 'with content that has multiple `eh`s', ->
    it 'should send an array of ehs', (done) ->
      matches.on 'data', (data) ->
        chai.expect(data).to.eql ['Eh...', 'eh?', 'EH?']
        done()
      word.send 'eh'
      surrounding.send true
      content.send 'Eh... eh? EH!'

describe 'DetermineEmotion component', ->
  c = null
  emotion = null
  content = null
  error = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'canadianness/DetermineEmotion', (err, instance) ->
      return done err if err
      c = instance
      content = noflo.internalSocket.createSocket()
      c.inPorts.content.attach content
      done()
  beforeEach ->
    emotion = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.outPorts.emotion.attach emotion
    c.outPorts.error.attach error
  afterEach ->
    c.outPorts.emotion.detach emotion
    c.outPorts.error.detach error

  describe 'with content eh', ->
    it 'should be neutral', (done) ->
      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'neutral'
        done()

      content.send new noflo.IP 'openBracket', null
      content.send new noflo.IP 'data', 'eh'
      content.send new noflo.IP 'closeBracket', null
      content.disconnect()

  describe 'with content eh!', ->
    it 'should be joyful', (done) ->
      emotion.on 'data', (data) ->
        chai.expect(data).to.eql 'joy'
        done()

      content.send new noflo.IP 'openBracket', null
      content.send new noflo.IP 'data', 'eh!'
      content.send new noflo.IP 'closeBracket', null
      content.disconnect()
