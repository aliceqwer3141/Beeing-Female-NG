;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__0506F038 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
akSpeaker.AddToFaction(FMA_AnnouncementBlockerFaction)
If FMA_MjollStoryQuest01.IsRunning() == 0
    FMA_MjollStoryQuest01.SetStage(10)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Faction Property FMA_AnnouncementBlockerFaction  Auto  


Quest Property FMA_MjollStoryQuest01  Auto  
