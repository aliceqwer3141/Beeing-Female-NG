Scriptname	FMA_MCMScript	extends		SKI_ConfigBase

Quest				Property	FMA_HandlerQuest	Auto  
ObjectReference		Property	TempleTrigger		Auto  

Event OnPageReset(String a_page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddToggleOptionST("RefreshUniqueList", "$Refrsh Unique List", "")
EndEvent


State RefreshUniqueList
	Event OnHighlightST()
		SetInfoText("$Restarts the handler quest and refreshes the list of unique NPCs.")
	EndEvent

	Event OnSelectST()
	; subhuman - commented these two for now since their values weren't filled in
;		TempleTrigger.Disable()
;		TempleTrigger.Enable()
;/	I attached my generic Quest Start/Stop script to your handlerquest
	setting stage to 10 starts it, setting stage 20 resets and stops it	/;
		FMA_HandlerQuest.SetCurrentStageID(20)	;	stop/reset quest
		FMA_HandlerQuest.SetCurrentStageID(10)	;	restart quest
		; subhuman - forces MCM page to update display.   Otherwise you have to exit then enter to see changes.
		ForcePageReset()
;		FMA_HandlerQuest.Stop()
;		FMA_HandlerQuest.Reset()
;		FMA_HandlerQuest.Start() 
		SetToggleOptionValueST(false)
	EndEvent
EndState

;/ Documentation:
	1) Kinda important.   SkyUI docs say the quest has to be attached to alias playerRef (14) you had it on alias player (07)
		SkyUI is very, very picky.  Have to do what they say pretty much exactly for it to work.
	2) the QF Start/Stop script I mentioned earlier is named _JSW_SUB_QF_StartStop.  Feel free to make your own if you prefer, it's 
		what I had handy and works pretty generically for the job. /;
