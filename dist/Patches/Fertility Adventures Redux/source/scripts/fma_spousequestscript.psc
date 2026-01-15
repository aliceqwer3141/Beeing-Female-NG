Scriptname FMA_SpouseQuestScript extends Quest  Conditional

Actor Property PlayerRef  Auto  
ReferenceAlias Property Spouse  Auto  
Faction Property TrackedFemFaction  Auto  

;Spouse's brain
;These are no longer relevant, system has changed to allow for multiple spouses
bool Property WantsBaby = true auto conditional
bool Property PlayerWantsBaby = false auto conditional
bool Property HasAskedBabyQuestion = false auto conditional
bool property SpouseEventOnCooldown = false auto conditional

Function SpouseSex(Actor akPartner)
	game.FadeOutGame(false, true, 5.0, 3.0)

	If PlayerRef.GetActorBase().GetSex() == 0 && akPartner.GetActorBase().GetSex() == 1
		AddSperm(PlayerRef, akPartner)
	elseif PlayerRef.GetActorBase().GetSex() == 1 && akPartner.GetActorBase().GetSex() == 0
		AddSperm(akPartner, PlayerRef)
	else
		;do nothing
	endif

	;ostim.StartScene(PlayerRef, Partner)
	;RegisterforModEvent("OStim_End", "EndScene")

EndFunction


Function AddSperm(Actor akGiver, Actor akReciever)
	int handle = ModEvent.Create("FertilityModeAddSperm")
		if (handle)
			ModEvent.PushForm(handle, akReciever as form)
			ModEvent.PushString(handle, akGiver.GetDisplayName())
			ModEvent.PushForm(handle, akGiver as form)
			ModEvent.Send(handle)
		endIf
EndFunction



Function SpouseEventCooldown()
	SpouseEventOnCooldown = true
	If (Spouse.GetReference() as actor).GetFactionRank(TrackedFemFaction) == -5 || (Spouse.GetReference() as actor).GetFactionRank(TrackedFemFaction) == -15
		RegisterforSingleUpdateGameTime(24)
	Else
		RegisterforSingleUpdateGameTime(72)
	EndIf
EndFunction

Event OnUpdateGametime()
	SpouseEventonCooldown = false
EndEvent

