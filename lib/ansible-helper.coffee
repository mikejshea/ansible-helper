AnsibleHelperView = require './ansible-helper-view'
{CompositeDisposable} = require 'atom'
fs = require 'fs'
path = require 'path'
# Dialog = require './dialog'
AddRole = require './add-role'

module.exports = AnsibleHelper =
  ansibleHelperView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @ansibleHelperView = new AnsibleHelperView(state.ansibleHelperViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @ansibleHelperView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:insert_copy_module': => @insert_copy_module()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:insert_template_module': => @insert_template_module()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:insert_yum_module': => @insert_yum_module()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:add_role': => @add_role()
    @subscriptions.add atom.commands.add 'atom-workspace', 'ansible-helper:test_dialog': => @test_dialog()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @ansibleHelperView.destroy()

  serialize: ->
    ansibleHelperViewState: @ansibleHelperView.serialize()

  toggle: ->
    console.log 'AnsibleHelper was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  insert_copy_module: ->
    @editor = atom.workspace.getActiveTextEditor();
    @editor.insertText("\n- name: http://docs.ansible.com/ansible/latest/copy_module.html\n  copy:\n    src: /srv/myfiles/foo.conf\n    dest: /etc/foo.conf\n    owner: foo\n    group: foo\n    mode: 0644\n");

  insert_template_module: ->
    @editor = atom.workspace.getActiveTextEditor();
    @editor.insertText("\n- name: http://docs.ansible.com/ansible/latest/template_module.html\n  template:\n    src: /mytemplates/foo.j2\n    dest: /etc/file.conf\n    owner: bin\n    group: wheel\n    mode: 0644\n");

  insert_yum_module: ->
    @editor = atom.workspace.getActiveTextEditor();
    @editor.insertText("\n- name: http://docs.ansible.com/ansible/latest/yum_module.html\n  yum:\n    name: '*'\n    state: latest\n");

  add_role: ->
    @p = atom.workspace.getActivePane();

    dialog = new AddRole(@p.items["0"].selectedPath, 'new-role')
    dialog.onDidCreateRole (createdRole) =>
      console.log 'onDidCreateRole!'
      dialog.close()
    dialog.attach()
