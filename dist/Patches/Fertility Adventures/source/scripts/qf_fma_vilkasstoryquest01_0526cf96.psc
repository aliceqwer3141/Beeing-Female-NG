;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 27
Scriptname QF_FMA_VilkasStoryQuest01_0526CF96 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Kust
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Kust Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Journal
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Journal Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Tilma
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Tilma Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Vilkas
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Vilkas Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Runil
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Runil Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Salvianus
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Salvianus Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Gravekeeper
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Gravekeeper Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Lowlife
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Lowlife Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
SetObjectiveDisplayed(20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
;Salvianus is dead. The quest will point to the lowlife instead.
SetObjectiveDisplayed(30)
Alias_Lowlife.GetReference().Enable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
SetObjectiveCompleted(60)
SetObjectiveDisplayed(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN CODE
SetObjectiveCompleted(100)
Stop()
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

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
SetObjectiveCompleted(30)
SetStage(45)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;The player has decided to look for Jergen
;The player must ask around the companions for clues
SetObjectiveDisplayed(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
;Stage that get's set when Salvianus' journal enters the invetory
Game.GetPlayer().AddItem(Alias_Journal.GetRef())
SetStage(32)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
;Vilkas will travel to Falkreath Cemetery
SetObjectiveCompleted(40)
SetObjectiveDisplayed(50)

If (Alias_Runil.GetReference() as actor).IsInFaction(FMA_VilkasStoryQuest01GravekeeperFaction) ||  (Alias_Kust.GetReference() as actor).IsInFaction(FMA_VilkasStoryQuest01GravekeeperFaction)
    FMA_VilkasStoryQuest01CemeteryScene.Start()
Else
    FMA_VilkasStoryQuest01AlternateCemeteryScene.Start()
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
SetObjectiveCompleted(50)
SetObjectiveDisplayed(60)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
SetObjectiveCompleted(20)
SetStage(40)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
SetObjectiveDisplayed(40)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;The player has been directed to Salvianus.
;If Salvianus is dead than some lowlife will be in his place.

SetObjectiveCompleted(10)

If (Alias_Salvianus.GetReference() as actor).IsDead() == 0
    SetStage(20)
Else
    SetStage(30)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
;stage for giving Vilkas the journal page
Game.GetPlayer().RemoveItem(Alias_Journal.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
;Stage 40 but for when Salvianus is already dead
SetObjectiveDisplayed(40)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_22
Function Fragment_22()
;BEGIN CODE
FMA_VilkasStoryQuest01EndScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Scene Property FMA_VilkasStoryQuest01AlternateCemeteryScene  Auto  

Scene Property FMA_VilkasStoryQuest01CemeteryScene  Auto  

Scene Property FMA_VilkasStoryQuest01EndScene  Auto  

Faction Property FMA_VilkasStoryQuest01GravekeeperFaction  Auto  
