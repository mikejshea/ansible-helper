AnsibleHelperView = require './ansible-helper-view'
{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'
AddRole = require './add-role'
AnsibleVault = require './ansible-vault'

module.exports = AnsibleHelper =
  ansibleHelperView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @ansibleHelperView = new AnsibleHelperView(state.ansibleHelperViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @ansibleHelperView.getElement(), visible: false)

    modules = fs.readFileSync("/home/mshea/github/ansible-helper/templates/files.json")
    jsonModules = JSON.parse(modules)
    console.log jsonModules

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:add_role': => @add_role()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:vault-decrypt': => @ansible_vault('decrypt')
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:vault-encrypt': => @ansible_vault('encrypt')

    @moduleText = {}
    for key, value of jsonModules
      moduleName = value.name
      moduleText = value.text
      moduleMenu = value.menu

      do (moduleName, moduleText, moduleMenu, @subscriptions, @insert_module, @moduleText) ->
        @subscriptions.add atom.commands.add 'atom-workspace', "ansible-helper:insert_module_#{moduleName}": => @insert_module(moduleName)
        atom.contextMenu.add {
          'atom-text-editor': [{
            label: moduleMenu,
            submenu: [
              {label: moduleName, command:"ansible-helper:insert_module_#{moduleName}"}
            ]
          }]
        }
        @moduleText[moduleName] = moduleText
    console.log this

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @ansibleHelperView.destroy()

  serialize: ->
    ansibleHelperViewState: @ansibleHelperView.serialize()

  toggle: ->
    # if @modalPanel.isVisible()
    #   @modalPanel.hide()
    # else
    #   @modalPanel.show()
    console.log 'ansible helper started'

  insert_module: (data)->
    console.log('inside insert_module')
    console.log data
    @editor = atom.workspace.getActiveTextEditor()
    @editor.insertText(@moduleText[data])

  add_role: ->
    @p = atom.workspace.getActivePane();

    dialog = new AddRole(@p.items["0"].selectedPath, 'new-role')
    dialog.onDidCreateRole (createdRole) =>
      console.log 'onDidCreateRole!'
      dialog.close()
    dialog.attach()

  ansible_vault: (state) ->
    console.log 'ansible_vault:' + state
    @p = atom.workspace.getActivePane();
    dialog = new AnsibleVault(@p.items["0"].selectedPath, state)
    dialog.onDidRunAnsibleVault (state) =>
      console.log 'onDidRunAnsibleVault!'
      dialog.close()
    dialog.attach()
