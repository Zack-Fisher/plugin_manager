@tool
class_name Plug_Config
# to be used as a singleton in the main plugin script.

# what the config file reads into
var repos: Dictionary = {}

func _init(path: String):
    # assume that it worked out
    repos = read_config(path)

func read_config(path: String) -> Dictionary:
    # Read the JSON file
    var file = FileAccess.open(path, FileAccess.READ)

    var json_data = file.get_as_text()
    file.close()
    repos = JSON.parse_string(json_data)

    print(repos)
    return repos
