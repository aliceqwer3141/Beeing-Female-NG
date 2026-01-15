;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 20
Scriptname QF__040073C0 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
;tracked actor has completed her second trimester and is 66% done
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;tracked actor has conceived for the first time
RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
;tracked actor is now 2 months pregnant or 20% done
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

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;tracked actor has less than two weeks until birth and is 95% done
;you can put stronger labor warning signs here
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
;tracked actor has completed the first trimester and is 32% done
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
;tracked actor has completed her second trimester and is 66% done
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

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
;tracked actor is now 1 month pregnant or11% done
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

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;tracked actor is not pregnant and has never been pregnant
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
;tracked actor has given birth for the first time
;this stage is the default for women who are not pregnant but have given birth before
;all pregnancies after this point will return to this stage after birth
TrackedActor.RemoveFromFaction(FMA_AnnouncementBlockerFaction)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_19
Function Fragment_19()
;BEGIN CODE
;tracked actor has less than two weeks until birth and is 95% done
;you can put stronger labor warning signs here
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

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
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

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
;tracked actor is now 1 month pregnant or11% done
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
;tracked actor is over 2 weeks pregnant 6% through her pregnancy
;this is when the first potential announcement may happen
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;tracked actor has conceived again
RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
;tracked actor is 50% through her pregnancy
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property trackedActor  Auto  

event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)
    If (Sender as Actor) == TrackedActor
        SetStage(100)
        TrackedActor.AddToFaction(FMA_RecentBirthFaction)
    Endif
EndEvent

Faction Property FMA_AnnouncementBlockerFaction  Auto  

Faction Property FMA_RecentBirthFaction  Auto  
