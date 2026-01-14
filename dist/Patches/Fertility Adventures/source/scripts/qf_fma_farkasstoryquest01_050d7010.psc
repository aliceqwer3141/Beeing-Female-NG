;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 16
Scriptname QF_FMA_FarkasStoryQuest01_050D7010 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Farkas_Chair
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Farkas_Chair Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY KidnappedHusband
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_KidnappedHusband Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY QuestGiver
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_QuestGiver Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY KidnappedWife
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_KidnappedWife Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY BanditBoss
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_BanditBoss Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Olfina
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Olfina Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Ysolda
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ysolda Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Saadia
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Saadia Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Farkas
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Farkas Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player_Chair
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player_Chair Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Bandit01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Bandit01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hulda
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Hulda Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hold
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_Hold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Bandit_Camp
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_Bandit_Camp Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;A citizen has asked for help finding a kidnapped couple
Alias_Bandit01.GetReference().Enable()
SetObjectiveDisplayed(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Player has accepted quest
FMA_FarkasStoryQuest01Scene01.Start()
SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;The victim wants revenge on the bandit leader
SetObjectiveDisplayed(60)
SetObjectiveCompleted(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;Player has rejected quest
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
Alias_KidnappedWife.GetReference().Disable()
Alias_KidnappedHusband.GetReference().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;Return to the victim
SetObjectiveCompleted(60)
SetObjectiveDisplayed(70)
FMA_FarkasStoryQuest01_BanditDeathScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
SetObjectiveCompleted(20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
SetObjectiveCompleted(70)
RegisterForSingleUpdateGameTime(24*7)
Alias_Bandit01.GetReference().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;Farkas will sit down at the table. The date has begun.
SetObjectiveDisplayed(20)
SetObjectiveCompleted(10)
Alias_KidnappedWife.GetReference().Enable()
Alias_KidnappedHusband.GetReference().Enable()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Scene Property FMA_FarkasStoryQuest01Scene01  Auto  


Actor Property KiddnapedWife  Auto  

Scene Property FMA_FarkasStoryQuest01_BanditDeathScene  Auto  

Event OnUpdateGameTime()
	SetStage(90)
EndEvent
