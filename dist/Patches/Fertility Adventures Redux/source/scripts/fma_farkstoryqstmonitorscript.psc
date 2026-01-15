Scriptname FMA_FarkStoryQstMonitorScript extends Quest  

Event OnStoryChangeLocation(ObjectReference akActor, Location akOldLocation, Location akNewLocation)
	If akNewLocation == DrunkenHuntsman.GetLocation()
		ParentQuest.SetStage(70)
	EndIf
endEvent


LocationAlias Property DrunkenHuntsman  Auto  
Quest Property ParentQuest  Auto  

