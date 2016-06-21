# 1) define our ports
noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Find all of the instances of `word` in `content` and send them out in a stream'
    inPorts:
      word:
        datatype: 'string' # could be array|string, which would be `all`
        description: 'the word we are looking for instances of'
        control: true
        required: true
      content:
        datatype: 'string'
        description: 'the content which we look for the word in'
        required: true
      surrounding: # could use a regex but this is a specific case
        datatype: 'boolean'
        description: 'whether to get surrounding characters, symbols before and after until space'
        default: false # if nothing is sent to it, this is the default when `get`ting from it
        control: true
    outPorts:
      matches:
        datatype: 'string'
        description: 'the resulting findings as a stream of data packets'
        required: true

  # we are only using data, so we do not need any brackets sent to the inPorts, pass them along
  c.forwardBrackets =
    word: 'matches'
    content: 'matches'
    surrounding: 'matches'
  c.process (input, output) ->
    return input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'word', 'content', (ip) -> ip.type is 'data'

    output.send matches: new noflo.IP 'openBracket', content

    word = input.getData 'word'
    content = input.getData 'content'
    r = /([.?!]*eh[.?!]*)/gi #/(?:[.?!]*)(eh?)(?:[.?!]*)/
    m = r.exec content
    # @TODO: matches regex
    matches = ['eh']

    for match in matches
      # if you just send content, it will automatically put it in a data ip
      # so this is the same as `output.send matches: new noflo.IP 'data', match`
      output.send matches: match

    output.send matches: new noflo.IP 'closeBracket', content
    output.done()
