;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 11
Scriptname QF_FMA_YsoldaStoryQuest01_0533579A Extends Quest Hidden

;BEGIN ALIAS PROPERTY Ahkari
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ahkari Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY chest
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_chest Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hold
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_Hold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ysolda
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ysolda Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hold2
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_Hold2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY BanditLair
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_BanditLair Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Loot
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Loot Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
SetObjectiveDisplayed(0)

If (Alias_Ahkari.GetReference() as actor).IsDead()
    SetStage(60)
EndIF
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
SetObjectiveCompleted(0)
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;Ysolda gives the player the toys
Game.GetPlayer().RemoveItem(Alias_Loot.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
SetObjectiveCompleted(20)
SetObjectiveDisplayed(30)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
;end
SetObjectiveCompleted(30)
Game.GetPlayer().AddItem(WoodenSword)
Game.GetPlayer().AddItem(Doll)
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
SetObjectiveCompleted(10)
SetObjectiveDisplayed(20)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


WEAPON Property WoodenSword  Auto  

MiscObject Property Doll  Auto  

