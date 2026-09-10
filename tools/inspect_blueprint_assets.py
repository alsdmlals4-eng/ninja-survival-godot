"""Read-only pixel inspection and derived atlas metadata; never edits raster pixels."""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
from PIL import Image
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/"docs/visual/candidates/blueprint-20260911"
GRIDS={"player":(4,3),"bongma":(6,5),"cheonsul":(6,5),"guiin":(6,5),"heukyeong":(6,5),"final":(3,2),"icons":(3,4),"vfx":(4,4),"floor":(1,1),"props":(3,1),"title":(1,1),"logo":(1,1),"equipment":(6,5),"combat":(1,1)}
CONSUMERS={"player":"scenes/player/player.tscn", "floor":"scenes/main/main_scene.tscn", "props":"scenes/main/main_scene.tscn", "title":"scenes/ui/title_screen.tscn", "logo":"scenes/ui/title_screen.tscn", "icons":"scenes/ui/rest_flow_ui.tscn", "equipment":"scenes/ui/rest_flow_ui.tscn", "combat":"docs/design/NINJA_SURVIVAL_HUMAN_BLUEPRINT.md", "vfx":"scripts/combat/basic_weapon_controller.gd"}
ENEMY_ROWS=["core_chaser","core_fast","core_heavy","elite","boss"]
ENCOUNTER_IDS={"bongma":["seal_chaser","shikigami_handler","barrier_carrier","mobile_array_caster","hundred_demon_array_master"],"cheonsul":["fire_mark_caster","water_vein_caster","lightning_chain_caster","five_element_tuner","heavenly_change_taoist"],"guiin":["surge_fighter","pressure_monk","ghost_blood_chaser","melee_chaos_captain","ghost_general"],"heukyeong":["shuriken_scout","poison_shadow_assassin","dark_mark_pursuer","shadow_chief","night_executioner"]}
EQUIPMENT_IDS=["taijutsu_training","protection_talisman","fortune_talisman","ninjutsu_training","enlightenment","regeneration_scroll","ultimate_treatise","school_emblem","katana","shuriken","bomb","water_style","lightning_style","fire_style","stealth_art","poison_needles","barrier_art","greater_summoning_circle","forbidden_talisman","water_mist","thunder_blade","explosive_bomb","small_pouch","long_pouch","square_pouch","tactical_t_pouch","ninjutsu_l_pouch","locked_book_ui","chest_token_ui","UNUSED"]
ICON_IDS=["bongma_hundred_demon_familiar","bongma_seal_chain","bongma_guardian_ward","cheonsul_flame_mark","cheonsul_water_vein_bind","cheonsul_lightning_chain_shift","guiin_ghost_blood_wave","guiin_afterimage_charge","guiin_asura_ring","heukyeong_shadow_needle","heukyeong_poison_mist","heukyeong_chain_execution"]

def measured_regions(alpha,cols,rows):
    """Find empty gutters near expected cells. Measurement only, not image editing."""
    a=np.asarray(alpha)>32;h,w=a.shape;cy=a.sum(axis=1)
    def cut(cost,expected,step,limit):
        candidates=range(max(1,int(expected-.30*step)),min(limit-1,int(expected+.30*step))+1)
        return min(candidates,key=lambda value:(int(cost[value]),abs(value-expected)))
    ys=[0]+[cut(cy,r*h/rows,h/rows,h) for r in range(1,rows)]+[h]
    rects=[];occupancy=[]
    for top,bottom in zip(ys,ys[1:]):
        cx=a[top:bottom].sum(axis=0)
        xs=[0]+[cut(cx,c*w/cols,w/cols,w) for c in range(1,cols)]+[w]
        occupancy.extend(int(cx[x]) for x in xs[1:-1])
        rects.extend([left,top,right-left,bottom-top] for left,right in zip(xs,xs[1:]))
    occupancy.extend(int(cy[y]) for y in ys[1:-1])
    return rects,occupancy

def inspect():
    provenance=json.loads((ART/"provenance.json").read_text(encoding="utf-8"))
    result={"scope":"NEW_CANDIDATES_NOT_CANON","user_approval":"PENDING","runtime":"NOT_RUN","assets":{}}
    for key,(cols,rows) in GRIDS.items():
        path=ART/(key+".png")
        if not path.exists():raise ValueError("Missing "+key)
        with Image.open(path) as image:
            w,h=image.size;alpha=image.getchannel("A") if image.mode=="RGBA" else None
            hist=alpha.histogram() if alpha else None
            required_alpha=key not in ("floor","title","combat")
            alpha_ok=alpha is not None and hist[0]>0 and sum(hist[240:])>0
            regions=[]
            measured,cut_pixels=measured_regions(alpha,cols,rows) if alpha is not None else (None,[])
            for row in range(rows):
                for col in range(cols):
                    x0,y0=round(col*w/cols),round(row*h/rows);x1,y1=round((col+1)*w/cols),round((row+1)*h/rows)
                    entry={"index":row*cols+col,"rect":[x0,y0,x1-x0,y1-y0],"pivot_normalized":[.5,.9],"pivot_state":"PROPOSED_NOT_MOTION_VERIFIED"}
                    if measured:entry["rect"]=measured[entry["index"]]
                    if key=="equipment":entry["logical_id"]=EQUIPMENT_IDS[entry["index"]]
                    if key=="icons":entry["logical_id"]=ICON_IDS[entry["index"]]
                    if key in ("bongma","cheonsul","guiin","heukyeong"):
                        entry["role"]=ENEMY_ROWS[row];entry["pose"]=["idle","walk_contact_a","walk_contact_b","prepare","release","death"][col]
                        entry["logical_id"]=ENCOUNTER_IDS[key][row]
                    regions.append(entry)
            if alpha:
                nonzero=1-hist[0]/(w*h)
                outer=[alpha.getpixel((0,0)),alpha.getpixel((w-1,0)),alpha.getpixel((0,h-1)),alpha.getpixel((w-1,h-1))]
                # Report, do not erase bleed or infer quality from one numeric threshold.
                edges=[]
                for c in range(1,cols):
                    x=round(c*w/cols);edges.append(round(sum(alpha.getpixel((x,y))>32 for y in range(h))/h,4))
                for r in range(1,rows):
                    y=round(r*h/rows);edges.append(round(sum(alpha.getpixel((x,y))>32 for x in range(w))/w,4))
            else:nonzero=None;outer=None;edges=[]
            note="실제 알파 확인; 셀/발 접점·연속 재생은 별도 검수" if alpha_ok else "불투명 배경 용도; 반복/화면 검수 별도"
            state="GENERATED_CANDIDATE"
            if required_alpha and not alpha_ok:state="REWORK_ALPHA";note="필수 알파 실패: 게임용 준비 완료 아님"
            if key=="combat":note="생성 목표 화면; 분리 게임 자산 또는 실제 캡처 아님"
            if key=="logo":note="투명 워드로고+메달; 각각 AtlasTexture 영역으로 배치 예정"
            if key=="floor":note="단일 바닥 후보; 반복 경계 검수 전 seamless 보장 없음"
            if any(cut_pixels):
                state="REWORK_REGION_BOUNDARY";note+="; 경계 픽셀 잔여: 절단/겹침 수정 필요"
            entry={"file":path.name,"sha256":hashlib.sha256(path.read_bytes()).hexdigest(),"width":w,"height":h,"mode":image.mode,"alpha_required":required_alpha,"alpha_channel_check":"PASS" if alpha_ok else ("FAIL" if required_alpha else "NOT_REQUIRED"),"alpha_nonzero_fraction":nonzero,"alpha_corners":outer,"grid_boundary_occupancy":edges,"grid":[cols,rows],"regions":regions,"state":state,"inspection_note":note,"consumer":CONSUMERS.get(key,"scenes/enemies/school_encounter_actor.tscn"),"consumer_binding":"PROPOSED_NOT_IMPLEMENTED","animation_continuity":"NOT_RUN","approval":"PENDING","provenance":provenance[key]}
            if key=="logo":entry["component_regions"]={"wordmark":[0,0,1540,724],"medal":[1540,0,w-1540,724],"note":"original candidate 2172x724; adjust only if source changes"}
            entry["measured_cut_occupied_pixels"]=cut_pixels
            result["assets"][key]=entry
    (ART/"manifest.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8",newline="\n")
    print(json.dumps({key:{"mode":v["mode"],"alpha":v["alpha_channel_check"],"cut_pixels":v["measured_cut_occupied_pixels"]} for key,v in result["assets"].items()},ensure_ascii=False,indent=2))
    return result

if __name__=="__main__":inspect()
