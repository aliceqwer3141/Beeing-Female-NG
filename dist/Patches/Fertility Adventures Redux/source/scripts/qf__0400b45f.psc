;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 7
Scriptname QF__0400B45F Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;The player is not pregnant
;This stage will start upon marriage to the NPC or some other significant event
;Use this stage for the "let's start a familly" conversation
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property TrackedFather  Auto  
Faction Property FMA_AnnouncementBlockerFaction  Auto  
Actor Property PlayerRef  Auto  

event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)
    If (Sender as Actor) == PlayerRef
        Reset()
        SetStage(0)
    Endif
EndEvent
