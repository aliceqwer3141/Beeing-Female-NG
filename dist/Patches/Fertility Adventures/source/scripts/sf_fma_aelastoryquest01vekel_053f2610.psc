;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 27
Scriptname SF_FMA_AelaStoryQuest01Vekel_053F2610 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN CODE
Vekel.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Vekel.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
Tonila.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Tonila.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
getowningquest().setstage(90)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Mjoll.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Mjoll.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ReferenceAlias Property Mjoll  Auto  

Activator Property SummonTargetFXActivator  Auto  

ReferenceAlias Property Tonila  Auto  

ReferenceAlias Property Vekel  Auto  
