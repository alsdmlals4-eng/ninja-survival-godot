"""Regression tests for document/asset preparation, not gameplay tests."""
import json
import tempfile
import unittest
from pathlib import Path
from PIL import Image
import numpy as np
import inspect_blueprint_assets as assets
import export_replanned_blueprint_pdf as book
import verify_blueprint_motion as motion

class PreparationTests(unittest.TestCase):
    def test_empty_gutters(self):
        a=np.zeros((100,100),dtype=np.uint8);a[10:30,10:30]=255;a[70:90,70:90]=255
        rects,cuts=assets.measured_regions(Image.fromarray(a),2,2)
        self.assertEqual(len(rects),4);self.assertFalse(any(cuts))
    def test_occupied_gutters_fail(self):
        _,cuts=assets.measured_regions(Image.new('L',(100,100),255),2,2)
        self.assertTrue(any(cuts))
    def test_ids_match_current_consumers(self):
        encounters=(book.ROOT/'scripts/data/encounter_catalog.gd').read_text(encoding='utf-8')
        ninjutsu=(book.ROOT/'scripts/data/ninjutsu_catalog.gd').read_text(encoding='utf-8')
        for ids in assets.ENCOUNTER_IDS.values():
            for ident in ids:self.assertIn('"'+ident+'"',encounters)
        self.assertEqual(len(set(assets.ICON_IDS)),12)
        for ident in assets.ICON_IDS:self.assertIn('"'+ident+'"',ninjutsu)
        self.assertEqual(len(set(assets.EQUIPMENT_IDS)),30)
    def test_no_unknown_directive(self):
        with tempfile.TemporaryDirectory(prefix='ninja-blueprint-test-') as temp:
            p=Path(temp)/'bad.md';p.write_text('@unknown\n')
            with self.assertRaises(ValueError):book.parse(p,book.styles(),{})
    def test_asset_manifest(self):
        data=json.loads((book.ART/'manifest.json').read_text(encoding='utf-8'))
        self.assertEqual(len(data['assets']),14)
        for k,v in data['assets'].items():
            self.assertEqual(v['approval'],'PENDING')
            self.assertFalse(any(v['measured_cut_occupied_pixels']),k)
            self.assertEqual(book.sha(book.ART/v['file']),v['sha256'])
    def test_player_mechanical_export(self):
        self.assertEqual(motion.run()['source_pixel_comparison'],'PASS_ALPHA_AND_VISIBLE_PIXELS_12_FRAMES')
    def test_approval_scope(self):
        text=book.BOOK.read_text(encoding='utf-8')
        for t in ['SWOT','SO','WO','ST','WT','기존 아이템 19종','최종 승인','실제 게임 촬영이 아니다']:
            self.assertIn(t,text)
    def test_pause_and_spawn_reservations_explicit(self):
        text=book.RULES.read_text(encoding='utf-8')
        for t in ['생성 예고 중 예약 수','매 프레임 부족분을 중복 예약하지 않는다','일시정지는 취소가 아니라']:
            self.assertIn(t,text)
    def test_candidates_excluded_from_engine(self):
        self.assertTrue((book.ART/'.gdignore').exists())
        for path in (book.ROOT/'scenes').rglob('*.tscn'):
            self.assertNotIn('blueprint-20260911',path.read_text(encoding='utf-8'))

if __name__=='__main__':unittest.main()
