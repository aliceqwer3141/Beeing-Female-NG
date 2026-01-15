Scriptname	FMA_MCMScript	extends		SKI_ConfigBase

Quest				Property	FMA_HandlerQuest	Auto  
ObjectReference		Property	TempleTrigger		Auto  
GlobalVariable Property FMA_SpouseApproachEnabled  Auto  
GlobalVariable Property PlayerFund  Auto  


Int SpouseContent

event OnPageReset(string page)
	{Called when a new page is selected, including the initial empty page}
	SetCursorFillMode(TOP_TO_BOTTOM)
	SpouseContent = AddToggleOption("Adult Spouse Interactions", FMA_SpouseApproachEnabled.GetValue())
endEvent


Event OnOptionSelect(int Option)
	If Option == SpouseContent
		If FMA_SpouseApproachEnabled.GetValue() == 1
			FMA_SpouseApproachEnabled.SetValue(0)
			ForcePageReset()
		Else
			FMA_SpouseApproachEnabled.SetValue(1)
			ForcePageReset()
		EndIf
	EndIf
EndEvent


