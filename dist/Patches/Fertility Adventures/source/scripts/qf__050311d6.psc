;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 20
Scriptname QF__050311D6 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;tracked actor has conceived and is now pregnant
RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;tracked actor has completed the first trimester and is 32% done
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

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;tracked actor is over 2 weeks pregnant 6% through her pregnancy
;this is when the first potential announcement may happen
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

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;tracked actor has less than two weeks until birth and is 95% done
;you can put stronger labor warning signs here
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;tracked actor is not pregnant
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

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property trackedActor  Auto  
Faction Property FMA_NonPlayerPregFaction  Auto
Faction Property FMA_AnnouncementBlockerFaction  Auto  
Faction Property FMA_RecentBirthFaction  Auto  
Faction Property FMA_PlayerParentFaction  Auto  

event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)
    If (Sender as Actor) == TrackedActor

        TrackedActor.AddToFaction(FMA_RecentBirthFaction)
        If TrackedActor.IsInFaction(FMA_AnnouncementBlockerFaction)
            TrackedActor.RemoveFromFaction(FMA_AnnouncementBlockerFaction)
        EndIf
        If (TrackedActor.IsInFaction(FMA_NonPlayerPregFaction) == 0) && (TrackedActor.IsInFaction(FMA_PlayerParentFaction) == 0)
            TrackedActor.AddToFaction(FMA_PlayerParentFaction)
        EndIf
        Reset()
        SetStage(0)
    Endif
EndEvent
