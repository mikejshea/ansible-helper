path = require 'path'
fs = require 'fs'
Dialog = require './dialog'

module.exports =
class AddRole extends Dialog
  constructor: (initialPath, newRoleName) ->

    @directoryPath = initialPath

    super
      prompt: "Enter the new role name:"
      defaultText: newRoleName
      select: false
      iconClass: 'icon-file-directory-create'

  onDidCreateRole: (callback) ->
    @emitter.on('did-create-role', callback)

  onConfirm: (newRole) ->
    newRole = newRole.replace(/\s+$/, '') # Remove trailing whitespace
    try
      newRolePath = path.join(@directoryPath, newRole)
      if fs.existsSync(newRolePath)
        @showError("Role #{newRole} Exists")
      else
        fs.mkdirSync(newRolePath)
        fs.mkdirSync(path.join(newRolePath, 'tasks'))
        fs.mkdirSync(path.join(newRolePath, 'files'))
        fs.mkdirSync(path.join(newRolePath, 'templates'))

        fs.writeFile(path.join(newRolePath, 'tasks', 'main.yml'), '---\n# New Role\n\n')
        atom.workspace.open(path.join(newRolePath, 'tasks', 'main.yml'))
        @emitter.emit('did-create-role', newRole)
    catch error
        @showError("#{error.message}.")
