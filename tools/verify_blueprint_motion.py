"""Read-only raster comparison and derived motion contract; no pixel editing."""
import hashlib
import json
from pathlib import Path
from PIL import Image
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'docs/visual/candidates/blueprint-20260911'

def run():
    meta=json.loads((ART/'motion/player-motion-packed.json').read_text())
    with Image.open(ART/'player.png') as source, Image.open(ART/'motion/player-motion-packed.png') as sheet:
        assert max(sheet.size)<=4096
        assert len(meta['frames'])==12
        durations=[100]*5+[200,80,100]+[120]*4
        for i,f in enumerate(meta['frames']):
            r=f['frame']; actual=np.asarray(sheet.crop((r['x'],r['y'],r['x']+r['w'],r['y']+r['h'])))
            x=(i%4)*362;y=(i//4)*362;expected=np.asarray(source.crop((x,y,x+362,y+362)))
            assert np.array_equal(actual[:,:,3],expected[:,:,3]),('alpha',i)
            visible=expected[:,:,3]>0
            assert np.array_equal(actual[visible],expected[visible]),('visible pixels',i)
            assert f['duration']==durations[i],i
    atlas=json.loads((ART/'manifest.json').read_text(encoding='utf-8'))
    clips={'player':{'run':[0,1,2,3],'idle':[4],'dash':[5],'hit':[6],'recover':[7],'death':[8,9,10,11]}}
    for key in ['bongma','cheonsul','guiin','heukyeong']:
        clips[key]={}
        for row in range(5):
            ident=atlas['assets'][key]['regions'][row*6]['logical_id']
            clips[key][ident]={'idle':[row*6],'walk':[row*6+1,row*6+2],'prepare':[row*6+3],'release':[row*6+4],'recover':[row*6],'death':[row*6+5],'hit':'existing tint overlay; no attack interruption'}
    files=['motion/player-motion.aseprite','motion/player-motion-packed.png','motion/player-motion-packed.json','player.png']
    result={'source_pixel_comparison':'PASS_ALPHA_AND_VISIBLE_PIXELS_12_FRAMES','aseprite_version':'1.3.18.5-dev','clips':clips,'enemy_source':'manifest.json regions; proposed SpriteFrames import, not yet engine-bound','durations':'NS-IMPLEMENTATION-PACKET section G; gameplay clocks own enemy pattern durations','hashes':{p:hashlib.sha256((ART/p).read_bytes()).hexdigest() for p in files},'runtime':'NOT_RUN','motion_continuity':'NOT_RUN','approval':'PENDING'}
    (ART/'motion/contract.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(result['source_pixel_comparison'])
    return result

if __name__=='__main__':run()
