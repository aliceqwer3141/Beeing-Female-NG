;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 10
Scriptname SF_FMA_AelaStoryQuest01Vekel_053F2611 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
getowningquest().setstage(90)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
Mjoll.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Mjoll.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Tonila.GetRef().PlaceAtMe(SummonTargetFXActivator)
Vekel.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Tonila.GetRef().Disable()
Vekel.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ReferenceAlias Property Vekel  Auto  

ReferenceAlias Property Tonila  Auto  

Activator Property SummonTargetFXActivator  Auto  

ReferenceAlias Property Mjoll  Auto  
