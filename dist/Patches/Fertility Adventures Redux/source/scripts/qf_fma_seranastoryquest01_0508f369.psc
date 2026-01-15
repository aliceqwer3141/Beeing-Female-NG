;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 31
Scriptname QF_FMA_SeranaStoryQuest01_0508F369 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Courier
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Courier Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Boss
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Boss Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Pie
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Pie Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Dungeon
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_Dungeon Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Valerica
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Valerica Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Item
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Item Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Letter
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Letter Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Serana
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Serana Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
SetObjectiveCompleted(71)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_29
Function Fragment_29()
;BEGIN CODE
SetObjectiveCompleted(50)
SetObjectiveDisplayed(52)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_24
Function Fragment_24()
;BEGIN CODE
SetObjectivedisplayed(80)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
;Vampire dagger is reclaimed, go back to valerica
SetObjectiveCompleted(55)
setObjectiveDisplayed(60)
Alias_Courier.GetReference().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
SetObjectiveCompleted(30)
SetObjectiveDisplayed(49)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_27
Function Fragment_27()
;BEGIN CODE
;end
SetObjectiveCompleted(80)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
;Player recieved letter from valerica and will now take serana to meet with her.
FMA_SeranaStoryQuest01ReturnToValericaScene.Start()
SetObjectiveCompleted(30)
SetObjectiveCompleted(45)
SetObjectiveCompleted(49)
setObjectiveDisplayed(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;Wait for Valerica to send Deathhound courier
setObjectiveCompleted(15)
setObjectiveDisplayed(30)

RegisterForSingleUpdateGameTime(72)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
;eat the pie
SetObjectiveDisplayed(71)
Game.GetPlayer().Additem(Alias_Pie.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
SetObjectiveCompleted(10)
setObjectiveDisplayed(15)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
;final scene starts
Game.GetPlayer().RemoveItem(Alias_Item.GetReference())
SetObjectiveCompleted(60)
Utility.Wait(4.0)
FMA_SeranaStoryQuest01EndScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
;Deathhoud courier on the move
Alias_Courier.GetReference().Enable()
;Fuck, I can't get the fucking deathhound to travel to the player for some fucking reason.
;I'll just use the vanilla courier

;(WICourier as WICourierScript).AddItemToContainer(Alias_Letter.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;kill vampire in cave
Alias_Item.getreference().Enable()
SetObjectiveCompleted(52)
setObjectiveDisplayed(55)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Serana will discuss telling Valerica about the baby with the player
FMA_SeranaStoryQuest01TellValericaScene.Start()
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;deathhound gives letter
Game.GetPlayer().Additem(Alias_Letter.GetReference())

SetObjectiveCompleted(30)
SetObjectiveDisplayed(45)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Scene Property FMA_SeranaStoryQuest01TellValericaScene  Auto  

Event OnUpdateGameTime()
	FMA_SeranaStoryQuest01.SetStage(40)
EndEvent

Quest Property FMA_SeranaStoryQuest01  Auto  

Scene Property FMA_SeranaStoryQuest01ReturnToValericaScene  Auto  

Scene Property FMA_SeranaStoryQuest01EndScene  Auto  

Quest Property WICourier  Auto  
