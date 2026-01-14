ScriptName	FMA_UpdateMEScript	extends		ActiveMagicEffect

FMA_HandlerQuestScript	Property	FMAHandler		auto	; the main script of FA main quest

actor					property	playerRef		auto	; player reference

spell					property	FMA_UpdateSpell	auto	; the spell that applies the ME that runs this script

; AFAIK these are what might need to be changed in a running quest.  Did I miss anything?
Actor[]			Property	QuestStarters					Auto
Float[]			Property	NextStagePercentage				Auto  
Int[]			Property	StageList						Auto  
Quest[]			Property	Quests							Auto

event	OnEffectStart(actor akTarget, actor akCaster)

	if (playerRef == akTarget) ; translates to: "if player fucked around with console commands, GTFO"
		FMAHandler.NextStagePercentage	=	NextStagePercentage
		FMAHandler.Quests				=	Quests
		FMAHandler.QuestStarters		=	QuestStarters
		FMAHandler.StageList			=	StageList
	endIf
	akTarget.RemoveSpell(FMA_UpdateSpell)	; suicide in scripted form

endEvent
