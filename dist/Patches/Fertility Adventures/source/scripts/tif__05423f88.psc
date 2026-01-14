;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__05423F88 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Haelga.GetRef().PlaceAtMe(SummonTargetFXActivator)
Nivenor.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Haelga.GetRef().Disable()
Nivenor.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Activator Property SummonTargetFXActivator  Auto  

ReferenceAlias Property Haelga  Auto  

ReferenceAlias Property Nivenor  Auto  
