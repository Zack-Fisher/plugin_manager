@tool
extends PanelContainer
class_name Plug_Dock

# our local copy of the repos dict
var _repos: Dictionary = {}

var _repo_container: VBoxContainer

func _update(repos: Dictionary):
    _repo_container = get_node("%RepoContainer")
    print(_repo_container)
    _repos = repos

    # clear the container
    for child in _repo_container.get_children():
        child.queue_free()
    
    # add the repos
    for repo in _repos:
        var repo_node: RepoDisplayer = preload("res://addons/plugin_manager/RepoDisplayer.tscn").instantiate()
        repo_node._name = repo
        repo_node._path = _repos[repo]
        _repo_container.add_child(repo_node)
