Scriptname	FMA_HandlerQuestScript	extends	Quest  


GlobalVariable	Property	PollingInterval					Auto
GlobalVariable	Property	PregnancyDuration				Auto

Actor			Property	PlayerRef						Auto
Actor[]			Property	QuestStarters					Auto	Hidden
Faction			Property	FMA_AnnouncementBlockerFaction	Auto  
Faction			Property	FMA_GenericPregFaction			Auto  
Faction			Property	FMA_NonPlayerPregFaction		Auto  
Faction			Property	FMA_PlayerPregFaction		Auto  
Faction			Property	FMA_PlayerParentFaction		Auto  
Float[]			Property	NextStagePercentage				Auto	Hidden
int				Property	QuestStartThreshold				Auto
Int[]			Property	StageList						Auto	Hidden
Quest			Property	FMA_GenericDialogueQuest		Auto  
Quest			Property	FMA_PlayerTrackingQuest			Auto  
Quest Property FMA_SpouseQuest  Auto  
Quest[]			Property	Quests							Auto	Hidden	; the CK won't try to autofill hidden properties
Spell			Property	FMA_UpdateSpell					Auto	; subhuman- new spell, when added to player forces your arrays to update
FormList Property FMA_AnnouncementQueueList  Auto  



event	GoForInit()

    FMA_PlayerTrackingQuest.SetStage(0)
    FMA_SpouseQuest.SetStage(0)
    FMA_GenericDialogueQuest.Start()
	PlayerLoadedGame()	; everything in there is common to both, so no need to duplicate it.

endEvent

event	PlayerLoadedGame()
	UnregisterForAllModEvents()	;	probably unnecessary, but since we're going to reregister it doesn't hurt to make sure
								;	nothing is accidentally carried over

	RegisterForModEvent("FM_ActorFactionsSet", "FAUpdateCycle")

	RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
	RegisterForModEvent("FertilityModeConception", "OnFertilityModeConception")

	;RegisterForSingleUpdateGameTime(24)
endEvent


;Event OnUpdateGameTime()
;Daily Maintenance
	;Check if there are pregnant women who haven't announced yet
	;If FMA_AnnouncementQueueList.GetSize() >= 1 && FMA_LetterQuest.IsRunning() == 0
		;FMA_LetterQuest.Start()
	;EndIf
	;RegisterForSingleUpdateGameTime(24)
;EndEvent






event OnFertilityModeConception(string eventName, Form akSender, string motherName, string fatherName, int iTrackingIndex)

	; akSender is the woman in question and can be cast to an Actor object
	; motherName is the display name of akSender
	; fatherName is the display name of the current father
	; iTrackingIndex is the woman's location in the tracking arrays


	If (fatherName == PlayerRef.GetDisplayName())
		(akSender as Actor).SetFactionRank(FMA_PlayerPregFaction, 1)
		FMA_AnnouncementQueueList.AddForm(akSender as Actor)
	EndIf

endEvent  


event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)

	;sender is the woman in question and can be cast to an Actor object
	;actorIndex is the woman's location in the tracking arrays

	;Removal of factions used to control pregnancy related dialogue.

	; subhuman- don't even bother checking if they're in faction first, just do it.   Won't throw errors.
	If (Sender as Actor).GetFactionRank(FMA_PlayerPregFaction) == 1
		(Sender as Actor).SetFactionRank(FMA_PlayerParentFaction, 1)
	Endif

	FMA_AnnouncementQueueList.RemoveAddedForm(Sender as Actor)

	(Sender as Actor).RemovefromFaction(FMA_PlayerPregFaction)
	(Sender as Actor).RemovefromFaction(FMA_AnnouncementBlockerFaction)


endEvent



Faction Property _JSW_SUB_TrackedFemFaction  Auto  

Quest Property FMA_LetterQuest  Auto  
