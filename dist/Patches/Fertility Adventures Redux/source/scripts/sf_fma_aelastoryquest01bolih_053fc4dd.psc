;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname SF_FMA_AelaStoryQuest01BoliH_053FC4DD Extends Scene Hidden

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
GetOwningQuest().SetStage(110)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Nivenor.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Nivenor.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
Boli.GetRef().PlaceAtMe(SummonTargetFXActivator)
Haelga.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Boli.GetRef().Disable()
Haelga.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Activator Property SummonTargetFXActivator  Auto  

ReferenceAlias Property Boli  Auto  

ReferenceAlias Property Nivenor  Auto  

ReferenceAlias Property Haelga  Auto  
