Scriptname FMA_PregnancyTestScript extends ActiveMagicEffect  

Quest Property FMA_PlayerTrackingQuest  Auto  
Quest Property FMA_FatherFinderQuest  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
    If FMA_PlayerTrackingQuest.GetStage() == 0
        Debug.MessageBox("The liquid leaves a minor burning sensation on your tongue. You are not pregnant.")
    Else
        Debug.MessageBox("The liquid leaves a lingering sweetness on your tongue. You are pregnant.")
        If !FMA_FatherFinderQuest.GetStage() == 100
            FMA_FatherFinderQuest.SetStage(10)
        EndIf
    EndIf
endEvent

