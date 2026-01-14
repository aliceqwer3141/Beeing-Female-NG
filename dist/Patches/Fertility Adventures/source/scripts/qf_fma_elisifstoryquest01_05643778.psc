;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 16
Scriptname QF_FMA_ElisifStoryQuest01_05643778 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Silana
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Silana Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Odar
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Odar Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Bryling
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Bryling Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Letter
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Letter Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Freir
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Freir Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Elisif
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Elisif Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Sybille
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Sybille Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Erikur
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Erikur Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Falk
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Falk Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY GenericBackup
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_GenericBackup Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Bolgeir
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Bolgeir Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Erdi
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Erdi Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Una
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Una Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Nurse
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Nurse Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;Player has read the letter from Elisif and must meet her in the blue palace

SetObjectiveDisplayed(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
FMA_ElisifBedroomScene02.Start()
FMA_ElisifPostCourtScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
;Quest is triggered and a courier is sent to the player from Elisif

;(WICourier as WICourierScript).AddItemToContainer(Alias_Letter.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
;Court scene has completed
;If player is not in the legion, they will be told to join (stage 50)
SetObjectiveCompleted(20)
SetObjectiveDisplayed(40)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;Join the legion
SetObjectiveDisplayed(50)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
;Elisif has the player follow her to her quarters to speak privately.
;Pregancy is revealed.
FMA_ElisifBedroomScene.Start()
SetObjectiveCompleted(10)
SetObjectiveDisplayed(20)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
;The court is notified of the pregnancy
Utility.Wait(1.0)
FMA_ElisifCourtAnnouncementScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property WICourier  Auto  

Scene Property FMA_ElisifBedroomScene  Auto  

Scene Property FMA_ElisifCourtAnnouncementScene  Auto  

Scene Property FMA_ElisifBedroomScene02  Auto  

Scene Property FMA_ElisifPostCourtScene  Auto  
