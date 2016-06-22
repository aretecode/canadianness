noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Test using fbp-spec'
    inPorts:
      in:
        datatype: 'array'
        description: 'data we want to send'
        required: true
    outPorts:
      out:
        datatype: 'string'
        description: 'the data wrapped in brackets'
        required: true

  c.process (input, output) ->
    # if it is not data, remove it from the buffer
    return input.buffer.get().pop() if input.ip.type isnt 'data'
    return unless input.has 'in'

    # needs the extra closeBracket
    # because of the extra connect in translation layer
    output.send out: new noflo.IP 'openBracket'

    datas = input.getData 'in'
    unless Array.isArray datas
      datas = [datas]
    for data in datas
      output.send out: new noflo.IP 'data', data

    output.send out: new noflo.IP 'closeBracket'
    output.send out: new noflo.IP 'closeBracket'
    output.done()
