;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 36
Scriptname QF_FMA_AelaStoryQuest01_053A7F56 Extends Quest Hidden

;BEGIN ALIAS PROPERTY BearGhost
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_BearGhost Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PrayingMarker2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PrayingMarker2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY HuntingGroundsStartMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_HuntingGroundsStartMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Aela
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Aela Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY ElkGhost
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_ElkGhost Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY WolfSkjor
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_WolfSkjor Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Skjor
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Skjor Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY CampMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_CampMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY WolfGhost
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_WolfGhost Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY EndingMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_EndingMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PrayingMarker1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PrayingMarker1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY SkjorGhost
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SkjorGhost Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Boss
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Boss Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_32
Function Fragment_32()
;BEGIN CODE
;End Quest

Crab1.Enable()
Crab2.Enable()

stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_30
Function Fragment_30()
;BEGIN CODE
;Move player back to real world
Game.GetPlayer().RemoveAllItems()
PlayerChest.RemoveAllItems(Game.GetPlayer(), True)
Game.GetPlayer().moveto(alias_EndingMarker.GetRef())

(Alias_Aela.GetReference() as actor).UnequipAll()
(Alias_Aela.GetReference() as actor).EquipItem(NudeRing)

Alias_PrayingMarker1.GetReference().Disable()
Alias_PrayingMarker2.GetReference().Disable()

SetObjectiveCompleted(165)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_27
Function Fragment_27()
;BEGIN CODE
;kill the boss
SetObjectiveCompleted(60)
SetObjectiveDisplayed(140)

Alias_Boss.GetReference().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Alias_boss.GetReference().Enable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_35
Function Fragment_35()
;BEGIN CODE
;Player declined quest
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
;Ritual start
SetObjectiveCompleted(20)

Game.ForceThirdPerson()
Game.DisablePlayerControls(abLooking = false, abCamSwitch = true, abSneaking = true)
Game.SetPlayerAIDriven()
Game.ShowFirstPersonGeometry( false )
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
SetObjectiveDisplayed(10)

Game.GetPlayer().RemovePerk(BloodHarvest)

Alias_PrayingMarker1.GetReference().Enable()
Alias_PrayingMarker2.GetReference().Enable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
setObjectiveDisplayed(1)
SetObjectiveDisplayed(2)
SetObjectiveDisplayed(3)

Crab1.Disable()
Crab2.Disable()

Game.GetPlayer().AddPerk(BloodHarvest)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_28
Function Fragment_28()
;BEGIN CODE
;return to skjor
SetObjectiveCompleted(140)
SetObjectiveDisplayed(150)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;Wolf Skjor greets the player

Game.SetPlayerAIDriven(False)
Game.ShowFirstPersonGeometry(true)
Game.EnablePlayerControls()

Alias_Aela.GetReference().RemoveItem(NudeRing)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_29
Function Fragment_29()
;BEGIN CODE
;skjor turns into human
Alias_WolfSkjor.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Alias_WolfSkjor.GetRef().Disable()
Alias_WolfSkjor.GetRef().PlaceAtMe(Alias_Skjor.GetRef())
Alias_Skjor.GetRef().Enable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
;Go to the mating pool
SetObjectiveCompleted(60)
SetObjectiveDisplayed(70)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;Teleport to hunting grounds
Game.GetPlayer().moveto(alias_HuntingGroundsStartMarker.GetRef())
Game.GetPlayer().RemoveAllItems(PlayerChest, True)
SetStage(40)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_22
Function Fragment_22()
;BEGIN CODE
;matchmaker segment is over
SetObjectiveCompleted(80)
SetObjectiveDisplayed(110)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN CODE
;talk to arena guard
SetObjectiveCompleted(120)
SetObjectiveDisplayed(130)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
;the hunt is done
SetObjectiveDisplayed(60)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_34
Function Fragment_34()
;BEGIN CODE
;Objective points to triggerbox to leave the hunting grounds
SetObjectiveCompleted(150)
SetObjectiveDisplayed(165)
Alias_Skjor.GetRef().PlaceAtMe(SummonTargetFXActivator)
Utility.wait(1)
Alias_Skjor.GetRef().Disable()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_23
Function Fragment_23()
;BEGIN CODE
;talk to skjor
SetObjectiveCompleted(110)
SetObjectiveDisplayed(120)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
SetObjectiveDisplayed(20)
SetObjectiveCompleted(10)
FMA_AelaStoryQuest01RitualScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;The hunt is on
Alias_WolfGhost.GetReference().Enable()
Alias_ElkGhost.GetReference().Enable()
Alias_BearGhost.GetReference().Enable()

SetObjectiveDisplayed(50)
SetObjectiveDisplayed(51)
SetObjectiveDisplayed(52)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Perk Property BloodHarvest  Auto  

Scene Property FMA_AelaStoryQuest01RitualScene  Auto  

Scene Property FMA_AelaStoryQuest01MatingCricleScene  Auto  

Activator Property SummonTargetFXActivator  Auto  

Container Property FMA_HuntingGroundsChestPlayerInventory  Auto  

ObjectReference Property PlayerChest  Auto  

Actor Property Crab1  Auto  

Actor Property Crab2  Auto  

Armor Property NudeRing  Auto  
