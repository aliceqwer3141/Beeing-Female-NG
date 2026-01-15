Scriptname FMA_HuntingGroundsGhostDeathScript extends ReferenceAlias  

int Property Objective Auto

event onDeath (actor akKiller)
	GetOwningQuest().SetObjectiveCompleted(Objective)

	(FMA_AelaStoryQuest01 as FMA_AelaQuest01Script).EndHunt()

endEvent
Quest Property FMA_AelaStoryQuest01  Auto  
