;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__07858E99 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
FMA_FatherFinderQuest.SetStage(50)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Faction Property FMA_AnnouncementBlockerFaction  Auto  

Actor Property PlayerRef  Auto  

Quest Property FMA_FatherFinderQuest  Auto  

Faction Property FMA_PlayerParentFaction  Auto  
