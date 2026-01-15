;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 18
Scriptname QF_FMA_MjollStoryQuest02_051B0D64 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Mjoll
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Mjoll Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Aerin
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Aerin Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
;Aerin is convinced to return to his normal life
SetObjectiveCompleted(30)
SetObjectiveDisplayed(80)
(Alias_Aerin.GetReference() as actor).SetOutfit(FineClothesOutfit02)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;Aerin is convinced to become a traveling adventurer
SetObjectiveCompleted(30)
SetObjectiveDisplayed(80)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
;Mjoll will present the letter to the player
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;The player has caused a fight with Aerin. This the point of no return where Aerin must be killed.
SetObjectiveCompleted(30)
SetObjectiveDisplayed(90)
(Aerin).StartCombat(Game.GetPlayer())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Startup phase
;Aerin will sit at home for a few days and pout
RegisterForSingleUpdateGameTime(72)
RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
;Mjoll has given the letter
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;Aerin will send a letter to Mjoll, challenging the player to a dual at Arcwind Point
RegisterForSingleUpdateGameTime(7*24)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;Aerin will leave his home for the mountains until Mjoll gives birth
(Alias_Aerin.GetReference() as actor).SetOutfit(MjollOutfit)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
;The player must travel to Arcwind Point and face Aerin
SetObjectiveDisplayed(30)
;(Alias_Aerin.GetReference() as actorbase).SetWeight(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;Aerin is convinced to live life as Riften's new protector
SetObjectiveCompleted(30)
SetObjectiveDisplayed(80)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
CompleteAllObjectives()
SetObjectiveDisplayed(80)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


Actor Property Mjoll  Auto 
Quest Property FMA_MjollStoryQuest02  Auto  

Event OnUpdateGameTime()
	If FMA_MjollStoryQuest02.GetStage() == 0
		FMA_MjollStoryQuest02.SetStage(10)
	ElseIf FMA_MjollStoryQuest02.GetStage() == 20
		FMA_MjollStoryQuest02.SetStage(21)
	EndIf
EndEvent

Event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)
	If (Sender as Actor) == Mjoll
		FMA_MjollStoryQuest02.SetStage(20)
	EndIf
EndEvent
 


Actor Property Aerin  Auto  

Outfit Property MjollOutfit  Auto  

Outfit Property FineClothesOutfit02  Auto  
