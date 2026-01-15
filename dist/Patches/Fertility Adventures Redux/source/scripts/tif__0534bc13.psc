;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__0534BC13 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
GetOwningQuest().setstage(30)
Game.GetPlayer().AddItem(Skooma, 3)
Game.GetPlayer().AddItem(StaminaPotion)
Game.GetPlayer().AddItem(HealthPotion)
Game.GetPlayer().AddItem(GoldNecklace)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Potion Property Skooma  Auto  

Armor Property GoldNecklace  Auto  

Potion Property HealthPotion  Auto  

Potion Property StaminaPotion  Auto  
