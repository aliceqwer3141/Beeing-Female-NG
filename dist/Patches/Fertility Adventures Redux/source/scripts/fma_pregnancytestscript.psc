Scriptname FMA_PregnancyTestScript extends ActiveMagicEffect  

Quest Property FMA_PlayerTrackingQuest  Auto  
Quest Property FMA_FatherFinderQuest  Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
    If akTarget.GetFactionRank(_JSW_SUB_TrackedFemFaction) <= 0
        Debug.MessageBox("The liquid leaves a minor burning sensation on your tongue. You are not pregnant.")
    Else
        Debug.MessageBox("The liquid leaves a lingering sweetness on your tongue. You are pregnant.")
        FMA_FatherFinderQuest.SetStage(0)
    EndIf
endEvent


Faction Property _JSW_SUB_TrackedFemFaction  Auto  
