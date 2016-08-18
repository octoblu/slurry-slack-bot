http   = require 'http'
_      = require 'lodash'
slack  = require 'slack'

class PostMessage
  constructor: ({@encrypted}) ->
    @token = @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data is required') unless data?
    return callback @_userError(422, 'data.channel is required') unless data.channel?
    return callback @_userError(422, 'data.text is required') unless data.text?

    { channel, text } = data
    message = {
      @token
      channel
      text
      as_user: true
    }
    slack.chat.postMessage message, (error, results) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: results
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = PostMessage
