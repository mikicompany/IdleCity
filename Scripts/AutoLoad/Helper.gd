extends Node2D

var PopupTextClass = preload("res://Prefab/UI/PopupText.tscn")
func GetScriptName(object):
	var script = object.get_script().resource_path.split("/")
	var scriptName = script[len(script)-1].trim_suffix(".gd")
	return scriptName

func ShowBuildTileOutline(bEnable):
	var tileOutlines = get_tree().get_nodes_in_group("TileOutline")[0]
	if bEnable:
		tileOutlines.Show()
	else:
		tileOutlines.Hide()

func GetFormattedAmount(amount):
	var score = str(amount)
	if amount <= 1:
		return score
	var i : int = score.length() - 3
	while i > 0:
		score = score.insert(i, ",")
		i = i - 3
	return score

func AddPopup(contentTitle, contentDescription, newContent):
	Finder.GetContentPopup().ShowPopup(contentTitle, contentDescription, newContent)

func AddPopupText(position, textContent):
	var instance = PopupTextClass.instantiate()
	instance.SetText(textContent)
	instance.global_position = position
	get_tree().root.add_child(instance)

func IsPopupVisible():
	return Finder.GetContentPopup().visible

func AddDescriptionPopup(object):
	Finder.GetDescriptionUI().Show(object)

func IsMouseOnControl():
	var mouse_position = get_viewport().get_mouse_position()
	var controls = get_tree().get_nodes_in_group("controls") # Assuming all controls are in a group named 'controls'

	for control in controls:
		if control.get_global_rect().has_point(mouse_position):
			return true
	return false

func ReparentNode(child: Node, new_parent: Node):
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.add_child(child)


func GetBuildingFromGlobalSpawnArea(globalSpawnArea):
	var buildings = Finder.GetBuildings()
	for building in buildings.get_children():
		if building.IsInMoveMode() == false:
			for buildingArea in building.GetGlobalSpawnArea():
				if buildingArea in globalSpawnArea:
					return building
	return null

func GetTileInfo(tile):
	var Tilemap = Finder.GetBuildTiles()
	var tileData = Tilemap.get_cell_source_id(0, tile)
	if tileData == -1:
		return null
	return tileData

func SetTile(tile, tileTypeIndex):
	var Tilemap = Finder.GetBuildTiles()
	Tilemap.set_cell(0, tile, tileTypeIndex, Vector2i(0,0))

func IsWaterTile(tile):
	var tileInfo = Helper.GetTileInfo(tile)
	if tileInfo != null:
		if tileInfo == GameResources.Tiles["Water"]:
			return true
	return false

func IsPlaceable(globalSpawnArea):
	if Helper.GetBuildingFromGlobalSpawnArea(globalSpawnArea):
			return false
	for area in globalSpawnArea:
		var tile = GetTileInTilemap(area)
		if Helper.IsWaterTile(tile):
			return false
	return true

func GetCustomMousePosition():
	return Vector2i(get_global_mouse_position()) - GameResources.TileOffset

func GetTileInTilemap(globalPosition):
	var Tilemap = Finder.GetBuildTiles()
	var tile = Tilemap.local_to_map(globalPosition)
	return tile

func SendLogMessageToPlayer(message):
	var instance = load("res://Prefab/UI/MessageLog.tscn").instantiate()

	var MessageContainer = get_tree().get_nodes_in_group("MessageContainer")[0]
	MessageContainer.add_child(instance)
	instance.UpdateText(message)

func FocusCamera(object):
	Finder.GetPlayer().Focus(object)

func FollowCamera(object):
	Finder.GetPlayer().Follow(object)
