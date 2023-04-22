@tool
extends EditorPlugin

const SHORTCUT = KEY_F7

const ADDON_PATH: String = "res://addons/"

# the JSON format reads from plugin folder name -> plugin repo folder
const CONFIG_PATH: String = "res://addons/plugin_manager/config.json"

enum State {
    IDLE,
    WORKING,
}

var state: State = State.IDLE

var _cfg: Plug_Config
var _interface: EditorInterface
var _dock: Plug_Dock

const SELF_PATH = "res://addons/plugin_manager/"

func _enter_tree():
    _interface = get_editor_interface()
    _dock = preload(SELF_PATH + "Dock.tscn").instantiate()
    add_control_to_dock(DOCK_SLOT_LEFT_UR, _dock)

    _dock.get_node("%Update").pressed.connect(update)

    update()

func _exit_tree():
    remove_control_from_docks(_dock)
    _dock.queue_free()

# add a custom shortcut to activate the update() function:
func _input(event):
    match state:
        State.WORKING:
            pass
        State.IDLE:
            if event is InputEventKey:
                if event.keycode == SHORTCUT:
                    update()

func _process(_delta):
    pass

func update():
    state = State.WORKING

    _cfg = Plug_Config.new(CONFIG_PATH)
    # display the new config in the dock
    _dock._update(_cfg.repos)

    for editor_name in _cfg.repos:
        # need repo_path as relative for the OS.execute()
        # svn cannot parse the res:// path
        # remember, we're in the root of the plugin_manager folder
        var res_repo_path = ADDON_PATH + editor_name

        # grab the actual abs path, not the godot res:// abspath
        var abs_repo_path = ProjectSettings.globalize_path(ADDON_PATH) + "/" + editor_name

        var repo_url = _cfg.repos[editor_name]
        check_and_update_repo(editor_name, res_repo_path, abs_repo_path, repo_url)

        _interface.set_plugin_enabled(editor_name, true)
    
    # done updating, reset state.
    state = State.IDLE

func check_and_update_repo(editor_name: String, res_repo_path: String, abs_repo_path: String, repo_url: String):
    # DirAccess returns null if it can't open the directory
    if not DirAccess.open(res_repo_path):
        # If the repo doesn't exist, clone it
        print("Repo not found, cloning:", editor_name)
        clone_repo(abs_repo_path, repo_url)
    else:
        # If the repo exists, update it
        print("Repo found, updating:", editor_name)
        update_repo(abs_repo_path, repo_url)

# custom abstraction over OS.execute() to make it easier to use
# either return something or nothing, don't worry about error code propagation
# we capture the stderr stream in the output, so we'll see it anyway.
func exec_command(command: String, args: Array):
    var output = []
    var err = OS.execute(command, args, output, true, false)
    var out = []
    return output

func clone_repo(repo_path: String, repo_url: String):
    var command = "svn"
    var args = ["export", repo_url, repo_path]
    var output = []
    print("executing the clone... ")
    print(exec_command(command, args))

func update_repo(repo_path: String, repo_url: String):
    var command = "svn"
    var args = ["update", repo_path]
    var output = []
    print("executing the update... ")
    print(exec_command(command, args))
