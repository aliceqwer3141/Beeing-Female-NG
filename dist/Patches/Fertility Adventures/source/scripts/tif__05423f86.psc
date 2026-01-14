;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__05423F86 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Tonila.GetRef().PlaceAtMe(SummonTargetFXActivator)
Mjoll.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Tonila.GetRef().Disable()
Mjoll.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Activator Property SummonTargetFXActivator  Auto  

ReferenceAlias Property Tonila  Auto  

ReferenceAlias Property Mjoll  Auto  
