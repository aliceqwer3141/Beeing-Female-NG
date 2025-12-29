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
