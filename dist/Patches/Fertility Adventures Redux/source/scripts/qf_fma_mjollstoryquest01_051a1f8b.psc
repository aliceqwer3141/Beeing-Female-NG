;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 17
Scriptname QF_FMA_MjollStoryQuest01_051A1F8B Extends Quest Hidden

;BEGIN ALIAS PROPERTY Aerin
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Aerin Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Mjoll
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Mjoll Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY AerinHouseExterior
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_AerinHouseExterior Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Aerin_Chair
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Aerin_Chair Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;Mjoll tells player about Aerin confessing his love to her
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
;Stage after Mjoll talks after the team confrontation
SetObjectiveCompleted(50)
SetStage(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
;Player has agreed to meet Aerin with Mjoll but needs to do stuff first.
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
;Aerin doesn't take the news well. He stays in his house like a hermit.
FMA_MjollStoryQuest02.SetStage(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
SetObjectiveCompleted(20)
SetStage(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;Mjoll decides she needs to tell Aerin the truth and reject him. She will wait outside his home.
SetObjectiveDisplayed(30)
FMA_MjollStoryQuest01VisitAerinTeamScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;Mjoll will wait outside Aerin's house for the player
SetObjectiveDisplayed(50)
SetObjectiveCompleted(40)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;Player has told Mjoll to solve her own problems
SetObjectiveDisplayed(12)
FMA_MjollStoryQuest01MjollVisitAerinSoloScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Startup Stage
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
;Mjoll and the player enter the home
SetObjectiveDisplayed(40)
SetObjectiveCompleted(30)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
;Stage if Aerin dies
FailAllObjectives()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
SetObjectiveDisplayed(20)
SetObjectiveCompleted(12)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Scene Property FMA_MjollStoryQuest01MjollVisitAerinSoloScene  Auto  

Scene Property FMA_MjollStoryQuest01VisitAerinTeamScene  Auto  

Quest Property FMA_MjollStoryQuest02  Auto  
