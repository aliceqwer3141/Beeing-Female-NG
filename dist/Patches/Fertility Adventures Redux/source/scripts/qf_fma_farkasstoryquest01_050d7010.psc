;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 22
Scriptname QF_FMA_FarkasStoryQuest01_050D7010 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Ysolda
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Ysolda Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY CaptiveMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_CaptiveMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Bandit01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Bandit01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player_Chair
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player_Chair Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY KidnappedHusband
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_KidnappedHusband Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY KidnappedWife
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_KidnappedWife Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY BanditCamp
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_BanditCamp Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Olfina
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Olfina Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Saadia
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Saadia Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hulda
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Hulda Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY BanditBoss
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_BanditBoss Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hold
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_Hold Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY QuestGiver
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_QuestGiver Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY BoundCaptiveMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_BoundCaptiveMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Farkas_Chair
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Farkas_Chair Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Note
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Note Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Farkas
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Farkas Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DrunkenHuntsman
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_DrunkenHuntsman Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DrunkenHuntsmanMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DrunkenHuntsmanMarker Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
Alias_KidnappedWife.GetReference().Disable()
Alias_KidnappedHusband.GetReference().Disable()
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

;BEGIN FRAGMENT Fragment_21
Function Fragment_21()
;BEGIN CODE
SetObjectiveCompleted(70)
SetObjectiveDisplayed(75)
(Alias_KidnappedWife.GetReference() as actor).SetRelationshipRank(Game.GetPlayer(), 1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;Returned the wife to the drunken huntsman
SetObjectiveCompleted(65)
SetObjectiveDisplayed(70)
;FMA_FarkasStoryQuest01_BanditDeathScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;The victim wants revenge on the bandit leader
SetObjectiveCompleted(50)
SetObjectiveDisplayed(60)
SetObjectiveDisplayed(61)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
;Escort the wife to the drunken huntsman
Alias_KidnappedWife.GetActorReference().SetRestrained(false)
SetObjectiveCompleted(61)
SetObjectiveDisplayed(65)
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

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;A citizen has asked for help finding a kidnapped couple
Alias_Bandit01.GetReference().Enable()
SetObjectiveDisplayed(50)
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

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
;Bandit leader is dead. Time to free the wife
SetObjectiveCompleted (60)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
SetObjectiveCompleted(75)
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

Actor poorSap = Alias_KidnappedWife.GetActorReference()

poorSap.MoveTo(Alias_CaptiveMarker.GetReference())
poorSap.EvaluatePackage()
poorSap.SetRestrained(true)
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
