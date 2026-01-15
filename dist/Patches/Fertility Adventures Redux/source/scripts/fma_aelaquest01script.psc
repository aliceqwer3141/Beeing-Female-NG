Scriptname FMA_AelaQuest01Script extends Quest  

Race Property Wolf auto
Race Property Bear auto
Race Property BlackBear auto
Race Property IceBear auto
Race Property Elk auto

bool Property GotWolfBlood auto conditional
bool Property GotBearBlood auto conditional 
bool Property GotElkBlood auto conditional 

ReferenceAlias Property Alias_Bear  Auto  
ReferenceAlias Property Alias_Wolf  Auto  
ReferenceAlias Property Alias_Elk  Auto  

Function GotBlood(ObjectReference deadThing)
	ActorBase Animal = (deadThing as Actor).GetLeveledActorBase()
	if     (Animal.GetRace() == Wolf)
		GotWolfBlood = true
		SetObjectiveCompleted(1)
	elseif (Animal.GetRace() == Bear) || (Animal.GetRace() == BlackBear) || (Animal.GetRace() == IceBear)
		GotBearBlood = true
		SetObjectiveCompleted(3)
	elseif (Animal.GetRace() == Elk) && (Animal.GetSex() == 0)
		GotElkBlood = true
		SetObjectiveCompleted(2)
	endif
	
	if (GotWolfBlood && GotBearBlood && GotElkBlood)
		SetStage(10)
	endif
EndFunction

Function EndHunt()
	If (Alias_Bear.GetReference() as Actor).IsDead() && (Alias_Wolf.GetReference() as Actor).IsDead() && (Alias_Elk.GetReference() as Actor).IsDead()
		SetStage(60)
	EndIF
EndFunction