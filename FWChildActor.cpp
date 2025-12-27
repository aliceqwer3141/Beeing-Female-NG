#include "skse64/GameAPI.h"
#include "skse64/GameData.h"
#include "skse64/GameTypes.h"
#include "skse64/GameForms.h"
#include "skse64/GameRTTI.h"
#include "skse64/ScaleformState.h"
#include "skse64/PapyrusActor.h"
#include "FWChildActor.h"

namespace FWChildActor {

	/*bool FWCastCombatSpell(StaticFunctionTag* base, Actor* thisActor) {
		return FWCastSpell(base, thisActor, ShildSpell | SummonSpell | AttackSpell);
	}

	bool FWCastSpell(StaticFunctionTag* base, Actor thisActor*, int SpellType) {

	}*/

	bool RegisterFuncs(VMClassRegistry* registry) {
		return true;
	}
}