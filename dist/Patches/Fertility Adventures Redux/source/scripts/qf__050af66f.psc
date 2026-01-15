;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 20
Scriptname QF__050AF66F Extends Quest Hidden

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property trackedActor  Auto  
Faction Property FMA_NonPlayerPregFaction  Auto
Faction Property FMA_AnnouncementBlockerFaction  Auto  
Faction Property FMA_RecentBirthFaction  Auto  
Faction Property FMA_PlayerParentFaction  Auto  

event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)
    If (Sender as Actor) == TrackedActor

        TrackedActor.AddToFaction(FMA_RecentBirthFaction)
        If TrackedActor.IsInFaction(FMA_AnnouncementBlockerFaction)
            TrackedActor.RemoveFromFaction(FMA_AnnouncementBlockerFaction)
        EndIf
        If (TrackedActor.IsInFaction(FMA_NonPlayerPregFaction) == 0) && (TrackedActor.IsInFaction(FMA_PlayerParentFaction) == 0)
            TrackedActor.AddToFaction(FMA_PlayerParentFaction)
        EndIf
        Reset()
        SetStage(0)
    Endif
EndEvent
