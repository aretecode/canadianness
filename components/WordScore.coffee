noflo = require 'noflo'
natural = require 'natural'
tokenizer = new natural.WordTokenizer()

exports.getComponent = ->
  c = new noflo.Component
    description: 'Find how the input words compare against the list of weighted words'
    inPorts:
      list:
        datatype: 'array'
        description: 'list of words we will use with the list of content'
        control: true
        required: true
      content:
        datatype: 'string'
        description: 'the content which we will determine the score of'
        required: true
    outPorts:
      score:
        datatype: 'number'
        description: 'the resulting number of comparing the content with the list'
        required: true

  # we are only using data, so we do not need any brackets sent to the inPorts, pass them along
  c.forwardBrackets =
    list: 'out'
    content: 'out'

  c.process (input, output) ->
    # our precondition, make sure it has both before trying to get the data
    return unless input.has 'list', 'content', (ip) -> ip.type is 'data'

    # get the data
    #content = input.getData 'content'
    #list = input.getData 'list'
    # @TODO: temporary hack since getData does not behave as one expects, change when fixed
    content = ((input.getStream('content').filter (ip) -> ip.type is 'data').map (ip) -> ip.data)[0]
    list = input.getStream(null, 'list')[0].data

    # our base score we will send out
    score = 0

    # splits content into an array of words
    contents = tokenizer.tokenize content

    # go through each of the comparisons in the list
    # if it is Canadian: 1, American: -1, British: .5, None: 0
    wordScore = (word) ->
      for comparison in list
        if word not in comparison["American"].split " "
          if word in comparison["Canadian"].split " "
            return 1
          else if word in comparison["British"].split " "
            return 0.5
        else
          return -1
      return 0

    for data in contents
      score += wordScore data

    # we could do `output.sendDone score` if we wanted
    # since there is only one outport it will know which one we mean
    output.sendDone score: score
