path = require 'path'
fs = require 'fs'
Dialog = require './dialog'

module.exports =
class AddRole extends Dialog
  constructor: (initialPath, newRoleName) ->

    @directoryPath = initialPath

    super
      prompt: "Enter the new role name:"
      newRole: newRoleName
      select: false
      iconClass: 'icon-file-directory-create'

  onDidCreateRole: (callback) ->
    @emitter.on('did-create-role', callback)

  onConfirm: (newRole) ->
    newRole = newRole.replace(/\s+$/, '') # Remove trailing whitespace

    # try
    #   if fs.existsSync(newPath)
    #     @showError("'#{newPath}' already exists.")
    #   else if @isCreatingFile
    #     if endsWithDirectorySeparator
    #       @showError("File names must not end with a '#{path.sep}' character.")
    #     else
    #       fs.writeFileSync(newPath, '')
    #       repoForPath(newPath)?.getPathStatus(newPath)
    #       @emitter.emit('did-create-file', newPath)
    #       @close()
    #   else
    #     fs.makeTreeSync(newPath)
    #     @emitter.emit('did-create-directory', newPath)
    #     @cancel()
    # catch error
    #   @showError("#{error.message}.")
    try
      newRolePath = path.join(@directoryPath, newRole)
      if fs.existsSync(newRolePath)
        @showError("Role #{newRole} Exists")
      else
        fs.mkdirSync(newRolePath)
        fs.mkdirSync(path.join(newRolePath, 'tasks'))
        fs.mkdirSync(path.join(newRolePath, 'files'))
        fs.mkdirSync(path.join(newRolePath, 'templates'))

        # fs.closeSync(fs.openSync(path.join(newRole, 'tasks', 'main.yml'), 'w'));
        fs.writeFile(path.join(newRolePath, 'tasks', 'main.yml'), '---\n# New Role\n\n')
        atom.workspace.open(path.join(newRolePath, 'tasks', 'main.yml'))
        console.log newRole + '::' + @directoryPath
        @emitter.emit('did-create-role', newRole)
    catch error
        @showError("Hello: #{error.message}.")
