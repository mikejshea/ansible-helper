path = require 'path'
fs = require 'fs'
Dialog = require './dialog'
exec = require('child_process').exec
{spawn} = require 'child_process'

module.exports =
class AnsibleVault extends Dialog
  constructor: (initialPath, state) ->

    @directoryPath = initialPath
    @vaultState = state

    super
      prompt: "Enter the vault password:"
      defaultText: ''
      select: false
      iconClass: 'icon-file-directory-create'

  onDidRunAnsibleVault: (callback) ->
    @emitter.on('did-run-ansible-vault', callback)

  onConfirm: (defaultText) ->
    defaultText = defaultText.replace(/\s+$/, '') # Remove trailing whitespace
    pwdFile = path.join(path.dirname(@directoryPath), 'pwd.txt')
    try
      # newRolePath = path.join(@directoryPath, newRole)
      if !fs.existsSync(@directoryPath)
        @showError("File #{newRole} does not exist")
      else
        console.log 'running vault on file:' + @directoryPath

        console.log 'pwdFile=' + pwdFile
        fs.writeFile(pwdFile, defaultText)

        av = spawn 'ansible-vault', ["#{@vaultState}", "#{@directoryPath}", "--vault-password-file", "#{pwdFile}"]
        av.stderr.on 'data', (data) ->
          console.log "Error: " + data
          atom.notifications.addInfo(data.toString())

        av.stdout.on 'data', (data) ->
          console.log data.toString()

        av.on 'close', (data) =>
          console.log 'closing av:: ' + data
          atom.workspace.open(@directoryPath)
          @emitter.emit('did-run-ansible-vault', 'hello!')
          fs.unlinkSync(pwdFile);

    catch error
      console.log 'in catch error'
      @showError(" #{error.message}.")
