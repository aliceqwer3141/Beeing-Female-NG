Scriptname	FMA_HandlerAlias	extends	ReferenceAlias

FMA_HandlerQuestScript		Property		FMAHandler		Auto	; the main FA script

actor	property	playerRef	Auto		; could be a reference to the player, but as of right now it's unused

event	OnInit()

	if (FMAHandler as quest).IsRunning()
		FMAHandler.GoForInit()
	endIf
	;/	so, you're wondering WTF that is, right?   Read the CK wiki page on the OnInit() block
		for some asinine reason, it gets run twice on new games: once when Skyrim loads, and a 
		second tiem when the quest starts.   Caught that?   The first time the OnInit runs, the 
		quest isn't running yet!  So to prevent a script from throwing tons of papyrus log errors 
		due to this asinine design, have it stop if the quest isn't running. /;

endEvent

event	OnPlayerLoadGame()

	FMAHandler.PlayerLoadedGame()

endEvent
