;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 22
Scriptname QF_FMA_FatherFinderQuest_040022E8 Extends Quest Hidden

;BEGIN ALIAS PROPERTY TrueFather
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_TrueFather Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;Player failed to tell the father


SetObjectiveFailed(10)

Reset()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
;Quest Started

;Register for when the player gives birth
RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")

;Find the father
int index = Storage.TrackedActors.Find(PlayerRef)
actor father = Storage.CurrentFatherForm[index] as actor
Alias_TrueFather.ForceRefTo(Father)

If Father.IsDead()
    Debug.Notification("The father of your child is dead")
    SetStage(100)
Else
    SetObjectiveDisplayed(10)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_19
Function Fragment_19()
;BEGIN CODE
;The player told the father

SetObjectiveCompleted(10)

;Now that he's been told we can assign him to the current father alias in the player's tracking quest
CurrentFather.ForceRefTo(Alias_TrueFather.GetReference())

Reset()
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)
    If (Sender as Actor) == PlayerRef
        FMA_FatherFinderQuest.SetStage(100)
    EndIf
EndEvent


_JSW_BB_Storage Property Storage  Auto

Actor Property PlayerRef  Auto  

Quest Property FMA_FatherFinderQuest  Auto  


ReferenceAlias Property CurrentFather  Auto  
