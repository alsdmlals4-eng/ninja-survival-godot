extends RefCounted

# R-EQUIPMENT / R-WEAPON-CONTENT. Definitions are not owned items or bag cells.
const DEFINITIONS := {
	"katana": {"name": "일본도", "slot": "melee", "interval": 0.65, "damage": 10.0, "range": 112.0, "shape": "cone", "angle": 120.0, "price": 35},
	"dual_tanto": {"name": "쌍단도", "slot": "melee", "interval": 0.38, "damage": 6.0, "range": 80.0, "shape": "cone", "angle": 90.0, "price": 35},
	"naginata": {"name": "나기나타", "slot": "melee", "interval": 1.0, "damage": 17.0, "range": 180.0, "shape": "rectangle", "width": 48.0, "price": 45},
	"kusarigama": {"name": "사슬낫", "slot": "melee", "interval": 1.25, "damage": 14.0, "range": 150.0, "shape": "cone", "angle": 210.0, "price": 45},
	"shuriken": {"name": "수리검", "slot": "projectile", "interval": 0.75, "damage": 9.0, "range": 480.0, "speed": 560.0, "lifetime": 1.2, "radius": 8.0, "count": 1, "pierce": 0, "price": 20},
	"kunai": {"name": "쿠나이", "slot": "projectile", "interval": 0.9, "damage": 6.0, "range": 400.0, "speed": 640.0, "lifetime": 1.0, "radius": 6.0, "count": 2, "spread": 6.0, "pierce": 0, "price": 35},
	"shortbow": {"name": "단궁", "slot": "projectile", "interval": 1.1, "damage": 16.0, "range": 560.0, "speed": 760.0, "lifetime": 1.0, "radius": 6.0, "count": 1, "pierce": 1, "price": 45},
	"powder_bomb": {"name": "화약탄", "slot": "projectile", "interval": 1.6, "damage": 18.0, "range": 360.0, "shape": "delayed_blast", "delay": 0.45, "radius": 80.0, "price": 45},
	"ninja_suit": {"name": "닌자복", "slot": "outfit", "reduction": 0.05, "reduction_per_rank": 0.03, "price": 0},
}


static func definition(id: StringName) -> Dictionary:
	return Dictionary(DEFINITIONS.get(str(id), {})).duplicate(true)
