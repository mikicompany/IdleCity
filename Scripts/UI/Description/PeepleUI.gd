extends Panel

var trackedPeeple = null
var bIsFollowing = false
var bIsActive = false

func _ready():
	Finder.GetPlayer().connect("OnPlayerModeChange", Callable(self, "PlayerModeChange"))
	visible = false
	
func PlayerModeChange(bIsBuildMode):
	if bIsBuildMode:
		visible = false
	else:
		if bIsActive:
			visible = true
			
			
func Show(peeple):
	bIsActive = true
	StopFollowing()
	if trackedPeeple:
		trackedPeeple.disconnect("OnHappinessUpdate", Callable(self, "UpdateUI"))
		trackedPeeple.disconnect("OnJobUpdate", Callable(self, "JobUpdate"))
		trackedPeeple.disconnect("OnHouseUpdate", Callable(self, "HouseUpdate"))
	trackedPeeple = peeple
	trackedPeeple.connect("OnHappinessUpdate", Callable(self, "UpdateUI"))
	trackedPeeple.connect("OnJobUpdate", Callable(self, "JobUpdate"))
	trackedPeeple.connect("OnHouseUpdate", Callable(self, "HouseUpdate"))
	
	$LeftSide/PeepleName.text = peeple.GetPeepleName()		
	$LeftSide/PeepleFace.texture = peeple.GetTexture()
	$LeftSide/PeepleFace.modulate = peeple.GetModulation()
	
	UpdateUI()
	JobUpdate()
	HouseUpdate()
	visible = true

func UpdateUI():
	$RightSide/ProgressBar.value = trackedPeeple.GetHappiness()
	var gradeValue = GameResources.GetHappinessGrading(trackedPeeple.GetHappiness())
	if GameResources.GRADE.A == gradeValue:
		$RightSide/ProgressBar.modulate = Color.GREEN
	if GameResources.GRADE.B == gradeValue:
		$RightSide/ProgressBar.modulate = Color.GREEN_YELLOW
	if GameResources.GRADE.C == gradeValue:
		$RightSide/ProgressBar.modulate = Color.YELLOW
	if GameResources.GRADE.D == gradeValue:
		$RightSide/ProgressBar.modulate = Color.RED
		
	if bIsFollowing:
		$LeftSide/Button.text = "Unfollow"
	else:
		$LeftSide/Button.text = "Follow"

func JobUpdate():
	if trackedPeeple:
		$RightSide/WorkControl/Button.visible = trackedPeeple.GetWork() != null
		if trackedPeeple.GetWork():
			$RightSide/WorkControl/WorkName.text = trackedPeeple.GetWork().name
		else:
			$RightSide/WorkControl/WorkName.text = "Unemployed"

func HouseUpdate():
	if trackedPeeple:
		$RightSide/HouseControl/Button.visible = trackedPeeple.GetHouse() != null
		if trackedPeeple.GetHouse():
			$RightSide/HouseControl/HouseName.text = trackedPeeple.GetHouse().name
		else:
			$RightSide/HouseControl/HouseName.text = "Homeless"
	
func StopFollowing():
	if bIsFollowing:
		Helper.FollowCamera(null)
		bIsFollowing = false
		UpdateUI()

func _on_ToolButton_button_up():
	bIsActive = false
	visible = false
	StopFollowing()

func _on_Button_button_up():
	bIsFollowing = !bIsFollowing
	if trackedPeeple:
		if bIsFollowing:
			Helper.FollowCamera(trackedPeeple)
		else:
			Helper.FollowCamera(null)
			
	UpdateUI()

func _on_WorkButton_button_up():
	if trackedPeeple:
		if trackedPeeple.GetWork():
			Helper.FocusCamera(trackedPeeple.GetWork())
			StopFollowing()


func _on_HouseButton_button_up():
		if trackedPeeple:
			if trackedPeeple.GetHouse():
				Helper.FocusCamera(trackedPeeple.GetHouse())
				StopFollowing()
