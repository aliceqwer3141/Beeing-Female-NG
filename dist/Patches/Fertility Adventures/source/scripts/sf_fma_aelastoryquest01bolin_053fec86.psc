;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname SF_FMA_AelaStoryQuest01BoliN_053FEC86 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
GetOwningQuest().SetStage(110)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
Nivenor.GetRef().PlaceAtMe(SummonTargetFXActivator)
Boli.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Nivenor.GetRef().Disable()
Boli.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
Haelga.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Haelga.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Activator Property SummonTargetFXActivator  Auto  

ReferenceAlias Property Boli  Auto  

ReferenceAlias Property Haelga  Auto  

ReferenceAlias Property Nivenor  Auto  
