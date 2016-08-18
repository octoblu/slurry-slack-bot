http    = require 'http'
_       = require 'lodash'
slack = require 'slack'
MeshbluHttp = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

class RegularBot
  constructor: ({@encrypted, @auth, @userDeviceUuid}) ->
    meshbluConfig = new MeshbluConfig({@auth}).toJSON()
    meshbluHttp = new MeshbluHttp meshbluConfig
    @_throttledMessage = _.throttle meshbluHttp.message, 500, leading: true, trailing: false

  do: ({slurry}, callback) =>
    bot = slack.rtm.client()
    bot.destroy = bot.close

    bot.started (payload) =>
      return callback null, bot

    bot.message (data) =>
      message =
        devices: ["*"]
        data: data

      @_throttledMessage message, as: @userDeviceUuid, (error) =>
        console.error error if error?

    bot.listen(token: @encrypted.secrets.credentials.secret)

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = RegularBot
