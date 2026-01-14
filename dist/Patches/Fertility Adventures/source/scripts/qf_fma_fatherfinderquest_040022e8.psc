;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 18
Scriptname QF_FMA_FatherFinderQuest_040022E8 Extends Quest Hidden

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;The player has decided to find the non-unique father
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")

; begin code changed/added by subhuman
Actor father
; if (Game.GetModByName("Fertility Mode 3 Fixes and Updates.esp") != 255)
;     fatherName = Storage.GetCurrentFathersName(PlayerRef)
; else
;     Int PlayerIndex = Storage.TrackedActors.Find(PlayerRef)
;     fatherName = Storage.CurrentFather[playerIndex]
; endIf
int fatherCount = StorageUtil.FormListCount(PlayerRef, "FW.ChildFather")
if fatherCount > 0
	father = StorageUtil.FormListGet(PlayerRef, "FW.ChildFather", 0) as Actor
endif
Int StarterIndex = QuestStarterNames.Find(father.GetLeveledActorBase().GetName())
; end changes

if (StarterIndex != -1) && ((!Quests[starterIndex].IsRunning()) || (Quests[starterIndex].GetStage() < (20)))
    Quests[starterIndex].SetStage(20)
    SetStage(20)
ElseIf (starterIndex == -1)
    SetStage(30)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
;The quest is waiting to be used
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;The father was told or the player decied to opt out
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
;The father is not unique. Will the player try to find the father?
int ibutton = FMA_GenericFatherOptInMessage.show()  
    If ibutton == 1                                   ;The playerdoesn't want to find the father of their child
        FMA_FatherFinderQuest.SetStage(100)
    ElseIf ibutton == 0
         FMA_FatherFinderQuest.SetStage(40)
    EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
;The player's baby daddy is unique. Time to tell them.
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

String[] Property QuestStarterNames  Auto  

Quest[] Property Quests  Auto  

Actor Property PlayerRef  Auto  

Quest Property FMA_FatherFinderQuest  Auto  

Message Property FMA_GenericFatherOptInMessage  Auto  
