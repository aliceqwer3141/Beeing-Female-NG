;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname QF_FMA_LetterQuest_06759170 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Preggo
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Preggo Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Letter
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Letter Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Int N=0

While n < FMA_AnnouncementQueueList.GetSize()
    Actor Target = (FMA_AnnouncementQueueList.GetAt(N) as actor)
    If Target.IsDead() || Target.IsInFaction(FMA_AnnouncementBlockerFaction)
        FMA_AnnouncementQueueList.RemoveAddedForm(Target)
    EndIf
EndWhile
SetStage(5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
;player reads the letter
Stop()
Reset()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
(WICourier as WICourierScript).AddItemToContainer(Alias_Letter.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Book Property FMA_GenericAnnouncementLetter  Auto  

FormList Property FMA_AnnouncementQueueList  Auto  

Faction Property _JSW_SUB_TrackedFemFaction  Auto  


Quest Property WICourier  Auto  

Faction Property FMA_AnnouncementBlockerFaction  Auto  
