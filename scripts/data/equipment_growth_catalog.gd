extends RefCounted

# R-CAMP initial playtest data. Neither presentation nor RNG owns these rules.
const SCHOOLS := ["bongma", "cheonsul", "guiin", "heukyeong"]
const COSTS := [20, 35, 55, 80]
const CHANCES := [80, 65, 50, 35]
const CONSUMABLES := {"potion": {"cost": 15, "healing": 25}, "emergency": {"cost": 25, "healing": 25, "capacity": 1}}
const POWERS := {
	"bongma": {
		"melee": {"kind": "hit_shield", "name": "봉마의 수호", "amount": 3.0, "cooldown": 4.0},
		"projectile": {"kind": "hit_shield", "name": "봉마의 수호", "amount": 3.0, "cooldown": 4.0},
		"outfit": {"kind": "periodic_shield", "name": "봉마의 결계", "amount": 8.0, "cooldown": 8.0}},
	"cheonsul": {
		"melee": {"kind": "elemental_hit", "name": "천술의 기운", "chance": 0.2, "ratio": 0.25},
		"projectile": {"kind": "elemental_hit", "name": "천술의 기운", "chance": 0.2, "ratio": 0.25},
		"outfit": {"kind": "reduction", "name": "천술의 방호", "amount": 0.05}},
	"guiin": {
		"melee": {"kind": "lifesteal", "name": "귀인의 흡혈", "ratio": 0.04, "cap": 2.0, "cooldown": 0.25},
		"projectile": {"kind": "lifesteal", "name": "귀인의 흡혈", "ratio": 0.03, "cap": 2.0, "cooldown": 0.25},
		"outfit": {"kind": "regeneration", "name": "귀인의 재생", "amount": 1.0, "cooldown": 2.0}},
	"heukyeong": {
		"melee": {"kind": "evasion", "name": "흑영의 잔상", "amount": 0.04},
		"projectile": {"kind": "evasion", "name": "흑영의 잔상", "amount": 0.04},
		"outfit": {"kind": "evasion", "name": "흑영의 잔상", "amount": 0.08}},
}

static func power(school: StringName, slot: StringName) -> Dictionary:
	return Dictionary(POWERS.get(str(school), {}).get(str(slot), {})).duplicate(true)

static func forge_quote(rank: int) -> Dictionary:
	if rank < 0 or rank >= COSTS.size(): return {"ok": false, "reason": &"rank_cap"}
	return {"ok": true, "rank": rank, "next_rank": rank + 1,
		"cost": COSTS[rank], "chance_percent": CHANCES[rank]}
