Scriptname	FMA_HandlerQuestScript	extends	Quest  
import StorageUtil

;GlobalVariable	Property	PollingInterval					Auto
;GlobalVariable	Property	PregnancyDuration				Auto

Actor			Property	PlayerRef						Auto
Actor[]			Property	QuestStarters					Auto	Hidden
Faction			Property	FMA_AnnouncementBlockerFaction	Auto  
Faction			Property	FMA_GenericPregFaction			Auto  
Faction			Property	FMA_NonPlayerPregFaction		Auto  
Float[]			Property	NextStagePercentage				Auto	Hidden
int				Property	QuestStartThreshold				Auto
Int[]			Property	StageList						Auto	Hidden
Quest			Property	FMA_GenericDialogueQuest		Auto  
Quest			Property	FMA_PlayerTrackingQuest			Auto  
Quest[]			Property	Quests							Auto	Hidden	; the CK won't try to autofill hidden properties
Spell			Property	FMA_UpdateSpell					Auto	; subhuman- new spell, when added to player forces your arrays to update

Faction					BeeingFemaleParentFaction
Bool					BeeingFemaleActive = false
FWSystem				BeeingFemaleSystem


event	GoForInit()

    FMA_PlayerTrackingQuest.SetStage(0)
    FMA_GenericDialogueQuest.Start()
	PlayerLoadedGame()	; everything in there is common to both, so no need to duplicate it.

endEvent

event	PlayerLoadedGame()

	UnregisterForAllModEvents()	;	probably unnecessary, but since we're going to reregister it doesn't hurt to make sure
								;	nothing is accidentally carried over
	; subhuman - add the "force array update" to the player
	PlayerRef.AddSpell(FMA_UpdateSpell, false)
    ;if (Game.GetModByName("Fertility Mode 3 Fixes and Updates.esp") != 255)
        ; subhuman- If my mod is found, register for the "maintenence is done" modevent and exit out of this
        ; withOUT registering for a timed update.  You now have a new function, called FAUpdateCycle()
        ; scroll down to see it.  Every time I finish an update I send the "FM_ActorFactionsSet" event,
        ; and now that you're registered for that event the game will automagically run your new FAUpdateCycle
        ; function each time.
        ; Yes.  I *totally* stole your idea of putting pregnant actors into their own faction! :)
        ;RegisterForModEvent("FM_ActorFactionsSet", "FAUpdateCycle")
    ;else
		; if not found, poll normally with FM
		; subhuman- change the first update to be soon, 6 game minutes instead of 1 hour
		
	;endIf
	; moved these two here, OnInit() and OnPlayerLoadGame() both call this function
    ;RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
    ;RegisterForModEvent("FertilityModeConception", "OnFertilityModeConception")
	RegisterForBeeingFemale()
	RegisterForSingleUpdateGameTime(0.1)
endEvent

function HandleBeeingFemaleState(Actor mother, int st)
	Debug.Trace("[FMA] HandleBeeingFemaleState mother=" + mother + " state=" + st)
	if mother == none
		return
	endif

	Bool isPregnancyState = (st >= 4) && (st <= 7)
	if isPregnancyState
		; Conception/pregnancy handling.
		Actor father = none
		int fatherCount = StorageUtil.FormListCount(mother, "FW.ChildFather")
		if fatherCount > 0
			father = StorageUtil.FormListGet(mother, "FW.ChildFather", 0) as Actor
		endif

		UpdateBeeingFemaleQuestStage(mother, st)
		UpdateBeeingFemaleFactions(mother, father)
	elseIf (st < 4) || (st == 8)
		; Labor/end handling.
		Debug.Trace("[FMA] BeeingFemale labor/end mother=" + mother + " state=" + st)
		mother.RemovefromFaction(FMA_NonPlayerPregFaction)
		mother.RemovefromFaction(FMA_GenericPregFaction)
		mother.RemovefromFaction(FMA_AnnouncementBlockerFaction)
	endIf
endFunction

Event	OnUpdateGameTime()
{If Fertility Mode fixes patch is NOT installed, this event does FA actor updates}

    Int n = 0
	; subhuman - moved checking the time before the while.   Need precision only to the day, and the
	; day is unlikely to change in the middle of an update.
	int today = Utility.GetCurrentGameTime() as int
    int trackedCount = StorageUtil.FormListCount(none, "FW.SavedNPCs")
	Debug.Trace("[FMA] OnUpdateGameTime today=" + today + " trackedCount=" + trackedCount)
    while (n < trackedCount)
		Actor tracked = StorageUtil.FormListGet(none, "FW.SavedNPCs", n) as Actor
		if tracked
			float lastConception = StorageUtil.GetFloatValue(tracked, "FW.LastConception", 0.0)
			if (lastConception > 0.0)
				int pregnantDay = (today - (lastConception as int))
				Debug.Trace("[FMA] Update tracked=" + tracked + " lastConception=" + lastConception + " pregnantDay=" + pregnantDay)
				if (pregnantDay >= QuestStartThreshold)
					; The actor is pregnant, check if she's a quest starter
					int starterIndex = QuestStarters.Find(tracked)
					if starterIndex != -1
						if ((!Quests[starterIndex].IsRunning()) || (Quests[starterIndex].GetCurrentStageID() == 0))
							Quests[starterIndex].SetCurrentStageID(10)
							;The pregnancy quest is not running or in the "pre-pregancy" stage. Start the Quest.
						ElseIf Quests[starterIndex].GetCurrentStageID() >= 10
						;The pregnancy quest is already running. Check to see if it's time to advance to the next stage.
							Int CurrentStageIndex = StageList.Find(Quests[starterIndex].GetCurrentStageID())
							Float NextStageThreshold = (GetBeeingFemalePregnancyDuration(tracked) * (NextStagePercentage[CurrentStageIndex]))
							Debug.Trace("[FMA] Check for advancing quest starterIndex=" + starterIndex + " currentStageIndex=" + CurrentStageIndex + " nextStageThreshold=" + NextStageThreshold)
							If PregnantDay > NextStageThreshold
								Debug.Trace("[FMA] Advancing quest starterIndex=" + starterIndex + " currentStageIndex=" + CurrentStageIndex + " nextStageThreshold=" + NextStageThreshold)
								Quests[starterIndex].SetCurrentStageID(Stagelist[CurrentStageIndex + 1])
							EndIf
						EndIf
					endIf
				EndIf   
			EndIf
		endif
        n += 1
    EndWhile
    RegisterForSingleUpdateGameTime(6)

EndEvent

function RegisterForBeeingFemale()
	BeeingFemaleActive = (Game.GetModByName("BeeingFemale.esm") != 255)
	if !BeeingFemaleActive
		return
	endif

	BeeingFemaleParentFaction = Game.GetFormFromFile(0x008448, "BeeingFemale.esm") as Faction
	if BeeingFemaleParentFaction == none
		return
	endif

	RegisterForModEvent("BeeingFemale", "OnBeeingFemaleEvent")
	SyncBeeingFemaleQuestStarters()
endFunction

function SyncBeeingFemaleQuestStarters()
	if !BeeingFemaleActive || BeeingFemaleParentFaction == none
		return
	endif

	int i = QuestStarters.Length
	while i > 0
		i -= 1
		Actor mother = QuestStarters[i]
		if mother
			HandleBeeingFemaleState(mother, mother.GetFactionRank(BeeingFemaleParentFaction))
		endif
	endWhile
endFunction



function UpdateBeeingFemaleQuestStage(Actor mother, int st)
	int starterIndex = QuestStarters.Find(mother)
	if starterIndex == -1
		Debug.Trace("[FMA] UpdateBeeingFemaleQuestStage skipped, not a quest starter: " + mother)
		return
	endif

	Quest pregnancyQuest = Quests[starterIndex]
	if pregnancyQuest == none
		Debug.Trace("[FMA] UpdateBeeingFemaleQuestStage missing quest for starterIndex=" + starterIndex)
		return
	endif

	int stageCount = StageList.Length
	if stageCount < 1
		return
	endif

	int targetIndex = 0
	if st >= 5
		targetIndex = 1
	endif
	if st >= 6
		targetIndex = 2
	endif
	if st >= 7
		targetIndex = 3
	endif
	if targetIndex >= stageCount
		targetIndex = stageCount - 1
	endif

	if (!pregnancyQuest.IsRunning()) || (pregnancyQuest.GetCurrentStageID() == 0)
		pregnancyQuest.SetCurrentStageID(StageList[0])
		Debug.Trace("[FMA] Started pregnancy quest stage=" + StageList[0] + " starterIndex=" + starterIndex)
	endif

	int targetStage = StageList[targetIndex]
	if (targetStage > 0) && (pregnancyQuest.GetCurrentStageID() < targetStage)
		Debug.Trace("[FMA] Set target stage=" + targetStage + " starterIndex=" + starterIndex + " state=" + st)
		pregnancyQuest.SetCurrentStageID(targetStage)
	endif
endFunction

function UpdateBeeingFemaleFactions(Actor mother, Actor father)
	int starterIndex = QuestStarters.Find(mother)
	if starterIndex == -1
		mother.AddtoFaction(FMA_GenericPregFaction)
	endIf

	if (father != PlayerRef) && (mother != PlayerRef)
		mother.AddtoFaction(FMA_NonPlayerPregFaction)
	endIf
endFunction

event OnBeeingFemaleEvent(string eventName, string argString, float argNum, form sender)
	if !BeeingFemaleActive || BeeingFemaleParentFaction == none
		return
	endif
	if argString != "stateChanged"
		return
	endif

	Actor mother = Game.GetForm(argNum as int) as Actor
	if mother == none
		return
	endif

	Debug.Trace("[FMA] BeeingFemale event stateChanged mother=" + mother + " state=" + mother.GetFactionRank(BeeingFemaleParentFaction))
	HandleBeeingFemaleState(mother, mother.GetFactionRank(BeeingFemaleParentFaction))
endEvent

FWSystem function GetBeeingFemaleSystem()
	if BeeingFemaleSystem == none
		BeeingFemaleSystem = Game.GetFormFromFile(0x04000D62, "BeeingFemale.esm") as FWSystem
	endIf
	return BeeingFemaleSystem
endFunction

float function GetBeeingFemalePregnancyDuration(Actor mother)
	FWSystem sys = GetBeeingFemaleSystem()
	return sys.getStateDuration(4, mother) + sys.getStateDuration(5, mother) + sys.getStateDuration(6, mother)
endFunction
