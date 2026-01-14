;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname SF_FMA_AelaStoryQuest01Matin_05423F84 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
If FMA_AelaStoryQuest01.GetStage() == 80
    FMA_AelaStoryQuest01.SetStage(90)
ElseIF FMA_AelaStoryQuest01.GetStage() == 90
    FMA_AelaStoryQuest01.SetStage(100)
ElseIf FMA_AelaStoryQuest01.GetStage() == 100
    FMA_AelaStoryQuest01.SetStage(110)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property FMA_AelaStoryQuest01  Auto  
