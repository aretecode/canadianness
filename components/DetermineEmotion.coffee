noflo = require 'noflo'

# https://en.wikipedia.org/wiki/Mode_(statistics)
findMode = (array) ->
  frequency = {}
  maxFrequency = 0
  result = undefined
  for v of array
    frequency[array[v]] = (frequency[array[v]] or 0) + 1
    if frequency[array[v]] > maxFrequency
      maxFrequency = frequency[array[v]]
      result = array[v]
  result

# could also pass in full contents here and determine distance from each other
exports.getComponent = ->
  c = new noflo.Component
    description: 'Find all of the instances of `word` in `content` and send them out in a stream'
    inPorts:
      content:
        datatype: 'string'
        description: 'the content which we look for the word in'
        required: true
    outPorts:
      emotion:
        datatype: 'string'
        description: 'the emotion based the content in ehs'
        required: true
      error:
        datatype: 'object'

  # we are using brackets to group the stream, so we do not want to forward them
  c.process (input, output) ->
    return unless input.hasStream 'content'
    contents = input.getStream 'content'
    contents = contents.filter (ip) -> ip.type is 'data'
    contents = contents.map (ip) -> ip.data

    matches = []

    emotions =
      joy: ['eh!']
      neutral: ['eh']
      amusement: ['eh?', 'Eh?', 'Eh??']
      fear: ['eH??', 'eh??']
      surprise: ['eh !?', 'EH!?']
      anticipation: ['eh?!']
      excitment: ['EH!', 'eH!']
      sadness: ['...eh', '...eh...', '..eh', 'eh..', '..eh..']
      anger: ['EH!?', 'EH?']

    for content in contents
      for emotion, data of emotions
        if content in data
          matches.push emotion

    if matches.length is 0
      mode = 'neutral'
    else
      mode = findMode matches

    output.sendDone emotion: mode
