;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 15
Scriptname SF_FMA_AelaStoryQuest01Matin_053EAEFB Extends Scene Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Vekel.GetRef().PlaceAtMe(SummonTargetFXActivator)
Tonila.GetRef().PlaceAtMe(SummonTargetFXActivator)
Mjoll.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Vekel.GetRef().Enable()
Tonila.GetRef().Enable()
Mjoll.GetRef().Enable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Activator Property SummonTargetFXActivator  Auto  

ReferenceAlias Property Vekel  Auto  

ReferenceAlias Property Tonila  Auto  

ReferenceAlias Property Mjoll  Auto  
