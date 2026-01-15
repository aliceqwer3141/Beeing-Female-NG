;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 5
Scriptname QF_FMA_HandlerQuest_05000D61 Extends Quest Hidden

;BEGIN ALIAS PROPERTY PlayerAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerAlias Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; stage 10
	if !clearAlias && Alias_PlayerAlias
		Alias_PlayerAlias.ForceRefTo(playerRef)
	endIf
	Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
; stage 20
	if clearAlias
		Alias_PlayerAlias.Clear()
	endIf
	Reset()
	Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

actor	Property	playerRef	Auto

bool 	Property 	clearAlias	Auto  

;/	Three properties:
	theRef		: leave null if the quest doesn't use an alias
	playerRef	: should be self-evident
	clearAlias	: bool for whether or not to clear the alias at shutdown.  If the alias is always the player, set to false.   If it can
					change each time the quest starts, set to true.  If the quest doesn't have an alias, set to false. /;
