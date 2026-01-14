Scriptname FMA_SpouseFinderScript extends ObjectReference  

import game
import debug

Faction Property PlayerMarriedFaction  Auto  
Quest[] Property Quests  Auto  
Actor[] Property QuestStarters  Auto  
Actor Property PlayerRef  Auto  

auto STATE waitingForActor
	EVENT onTriggerEnter(objectReference triggerRef)
		; check for correct actor
		actor actorRef = triggerRef as actor
		if actorRef != None && actorRef.IsInFaction(PlayerMarriedFaction) && actorRef != PlayerRef
			Int StarterIndex = QuestStarters.Find(ActorRef)
			If !Quests[starterIndex].IsRunning()
				Quests[StarterIndex].SetStage(0)
			EndIf
		EndIf
	EndEvent
EndSTATE

