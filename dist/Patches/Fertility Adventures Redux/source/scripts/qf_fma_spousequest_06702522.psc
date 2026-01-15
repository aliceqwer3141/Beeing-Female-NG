;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname QF_FMA_SpouseQuest_06702522 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Quest is started

RegisterForModEvent("BeeingFemaleLabor", "OnBeeingFemaleLabor")
RegisterForModEvent("BeeingFemaleConception", "OnBeeingFemaleConception")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


event OnBeeingFemaleConception(Form akMother, int aiChildCount, Form akFather0, Form akFather1, Form akFather2)

endEvent  



event OnBeeingFemaleLabor(Form akMother, int aiChildCount, Form akFather0, Form akFather1, Form akFather2)

endEvent

Faction Property FMA_BabyMakerFaction  Auto  
