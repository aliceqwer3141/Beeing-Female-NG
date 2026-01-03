Scriptname FWLaborPainsBase extends activemagiceffect  

FWSystem property System auto
float property DamageBase auto
float property UpdateDelay auto
int property KindOfPains auto
bool property Silent = false auto
actor ActorRef


Event OnEffectStart(Actor akTarget, Actor akCaster)
	ActorRef=akTarget
	Utility.Wait(Utility.RandomFloat( (UpdateDelay*0.75) + 2, (UpdateDelay* 1.1) + 2))
	OnUpdateGameTime()
endEvent

function OnUpdateGameTime()
	float rnd=Utility.RandomFloat(-1.0,1.0)
	if Silent ;Tkc (Loverslab): optimization
	else;if Silent==false
		System.PlayPainSound(ActorRef,(DamageBase+rnd) *4)
	endif

	; Find the list of fathers
	int my_num_men = StorageUtil.FormListCount(ActorRef, "FW.ChildFather")
	float my_LaborPains_DamageScale = 0
	float temp_LaborPains_DamageScale = 0
	actor a = none
	race abr = none
	while my_num_men > 0
		my_num_men -= 1
		a = (StorageUtil.FormListGet(ActorRef, "FW.ChildFather", my_num_men) As Actor)
		if a
			temp_LaborPains_DamageScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace", 1.0)
			if(temp_LaborPains_DamageScale == 1.0)
				abr = a.GetRace()
				if abr
					temp_LaborPains_DamageScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace", 1.0)
				endIf
			endIf

			if(temp_LaborPains_DamageScale > my_LaborPains_DamageScale)
				my_LaborPains_DamageScale = temp_LaborPains_DamageScale
			endIf
		endIf
	endWhile
	my_LaborPains_DamageScale *= ((DamageBase + rnd) * (System.getDamageScale(3, ActorRef)))

	if(my_LaborPains_DamageScale > 0)
		System.DoDamage(ActorRef, my_LaborPains_DamageScale, KindOfPains)
	endIf
	If self as string == "[FWLaborPainsBase <None>]" ;Tkc (Loverslab): optimization
	else;If self as string != "[FWLaborPainsBase <None>]"
		RegisterForSingleUpdateGameTime( Utility.RandomFloat(UpdateDelay*0.75,UpdateDelay* 1.1))
	EndIf
endFunction

; 02.06.2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment