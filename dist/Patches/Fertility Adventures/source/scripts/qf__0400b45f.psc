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

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;Player is not pregnant
;This is the stage that gets set if the player agrees to have kids with the NPC
;Can be used to condition dialogue relevant to the situation like "any signs of pregnancy yet?"
;Optional of course
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
;Player is currently pregnant with the NPCs child
RegisterForModEvent("BeeingFemaleLabor", "OnBeeingFemaleLabor")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property TrackedFather  Auto  
Faction Property FMA_AnnouncementBlockerFaction  Auto  
Actor Property PlayerRef  Auto  

event OnBeeingFemaleLabor(Form akMother, int aiChildCount, Form akFather0, Form akFather1, Form akFather2)
    If (akMother as Actor) == PlayerRef
        Reset()
        SetStage(0)
    Endif
EndEvent
