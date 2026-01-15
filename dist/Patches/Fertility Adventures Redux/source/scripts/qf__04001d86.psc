;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 20
Scriptname QF__04001D86 Extends Quest Hidden

;BEGIN ALIAS PROPERTY CurrentFather
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_CurrentFather Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;tracked actor has conceived for the first time
;RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;tracked actor has less than two weeks until birth and is 95% done
;you can put stronger labor warning signs here
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
;tracked actor is now 2 months pregnant or 20% done
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;tracked actor is in her last month or 90% done
;you can put early labor warning signs here
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;tracked actor has completed the first trimester and is 32% done
;If the player hasn't confirmed her pregnancy through other means at this point she will get a notification
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;tracked actor is over 2 weeks pregnant 6% through her pregnancy
;this is when the first potential announcement may happen
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
;tracked actor is 50% through her pregnancy
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
;tracked actor has completed her second trimester and is 66% done
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;tracked actor is not pregnant and has never been pregnant
RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
RegisterForModEvent("FertilityModeConception", "OnFertilityModeConception")
;RegisterForSleep()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
;tracked actor is now 1 month pregnant or11% done
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property trackedActor  Auto  
Quest Property FMA_FatherFinderQuest  Auto  
Faction Property FMA_AnnouncementBlockerFaction  Auto  
Faction Property FMA_RecentBirthFaction  Auto  

event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)
If (Sender as actor) == TrackedActor
	(Alias_CurrentFather.GetReference() as actor).AddtoFaction(FMA_PlayerParentFaction)
	Alias_CurrentFather.Clear()
EndIf

endEvent

event OnFertilityModeConception(string eventName, Form akSender, string motherName, string fatherName, int iTrackingIndex)
If (akSender as actor) == TrackedActor
	RegisterForSleep()
EndIf

endEvent  

Event OnSleepStop(bool abInterrupted)
    If (FMA_FatherFinderQuest.GetStage() != 100) && (TrackedActor.GetFactionRank(TrackedFemFaction) >= 33)
        Debug.Messagebox("The size of your belly made getting out of bed silghtly awkward today. There's no denying it; you are pregnant. You should find the father.")
        FMA_FatherFinderQuest.SetStage(0)
        UnRegisterForSleep()
    Else
        RegisterForSleep()
    EndIf
EndEvent

Faction Property FMA_ChildAnnouncementBlockerFaction  Auto  

Faction Property TrackedFemFaction  Auto  


Faction Property FMA_PlayerParentFaction  Auto  
