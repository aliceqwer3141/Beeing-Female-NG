;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname QF_FMA_SpouseQuest_06702522 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Quest is started

RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
RegisterForModEvent("FertilityModeConception", "OnFertilityModeConception")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


event OnFertilityModeConception(string eventName, Form akSender, string motherName, string fatherName, int iTrackingIndex)

endEvent  



event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)

endEvent

Faction Property FMA_BabyMakerFaction  Auto  
