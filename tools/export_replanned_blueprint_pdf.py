"""Source-bound human Blueprint. Draws editable diagrams, never replacement game art."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

from PIL import Image as PILImage
from pypdf import PdfReader
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, Spacer, PageBreak, Image, Flowable, KeepTogether, CondPageBreak

from export_human_gdd_pdf import register_fonts, inline_markdown

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "docs/visual/candidates/blueprint-20260911"
BOOK = ROOT / "docs/design/NINJA_SURVIVAL_HUMAN_BLUEPRINT.md"
RULES = ROOT / "docs/design/NINJA_SURVIVAL_DETAILED_RULES.md"
PACKET = ROOT / "docs/design/NINJA_SURVIVAL_IMPLEMENTATION_PACKET.md"
SOURCES = ROOT / "docs/research/2026-09-11-blueprint-production-research.md"
OUTPUT = ROOT / "exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_20260911.pdf"
MANIFEST = ROOT / "docs/publication/NINJA_SURVIVAL_HUMAN_BLUEPRINT_20260911_MANIFEST.json"
W, H = landscape(A4)
CW = W - 88
NAVY = colors.HexColor("#142338")
GOLD = colors.HexColor("#AB8C57")
INK = colors.HexColor("#202C3D")
CREAM = colors.HexColor("#F5F1E8")
SCREEN_NAMES = {"title":"메인", "route":"시작·전장 선택", "combat":"군중 전투", "boss":"강적 패턴", "workbench":"통합 준비", "result":"결과", "awakening":"각성", "codex":"도감", "settings":"설정"}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Diagram(Flowable):
    def __init__(self, kind: str, width=CW, height=285):
        super().__init__()
        self.kind, self.width, self.height = kind, width, height

    def txt(self, text, x, y, size=10, color=CREAM):
        c=self.canv; c.setFillColor(color); c.setFont("NinjaGdd", size); c.drawString(x,y,text)

    def box(self,x,y,w,h,label="",fill=NAVY,size=10):
        c=self.canv;c.setFillColor(fill);c.setStrokeColor(GOLD);c.roundRect(x,y,w,h,4,fill=1,stroke=1)
        if label:self.txt(label,x+8,y+h/2-3,size)

    def raster(self,name,x,y,w,h):
        path=ART/(name+".png")
        if not path.exists():raise ValueError("Missing screen asset: "+name)
        self.canv.drawImage(str(path),x,y,w,h,preserveAspectRatio=False,mask="auto")

    def sprite(self,name,index,x,y,w,h):
        """PDF viewport over an unchanged atlas; no generated raster substitute."""
        data=json.loads((ART/"manifest.json").read_text(encoding="utf-8"))["assets"][name]
        rx,ry,rw,rh=data["regions"][index]["rect"];scale=min(w/rw,h/rh)
        c=self.canv;c.saveState();p=c.beginPath();p.rect(x,y,w,h);c.clipPath(p,stroke=0)
        c.drawImage(str(ART/(name+".png")),x-rx*scale,y-(data["height"]-ry-rh)*scale,width=data["width"]*scale,height=data["height"]*scale,mask="auto")
        c.restoreState()

    def screen(self,kind,x,y,w,h):
        c=self.canv;c.saveState();scale=min(w/720,h/405)
        c.translate(x+(w-720*scale)/2,y+(h-405*scale)/2);c.scale(scale,scale)
        viewport=c.beginPath();viewport.rect(0,0,720,405);c.clipPath(viewport,stroke=0)
        self.box(0,0,720,405,fill=colors.HexColor("#101B29"))
        if kind=="asset_composite":
            # Unchanged candidate textures composed in a PDF viewport, not a game capture.
            for row in range(2):
                for col in range(3):self.raster('floor',col*240,row*240,240,240)
            for i in range(12):
                family=['bongma','cheonsul','guiin','heukyeong'][i%4]
                self.sprite(family,(i%3)*6,30+(i%6)*110,65+(i//6)*160,72,86)
            self.sprite('player',0,320,158,92,92)
            self.sprite('vfx',0,374,166,70,70)
            self.txt('신규 후보 텍스처 조립 검수 · 실제 게임 화면 아님',18,375,13)
        elif kind in ("combat","boss"):
            self.raster("combat",0,0,720,405)
            self.box(12,367,695,28,fill=NAVY)
            self.txt("HP 100/100   대시 ● ●   04:32   오의 준비 [E / Y]             설정",24,377,12)
            self.txt("자동: 일본도 · 수리검 · 시작 인법",16,347,10)
            if kind=="boss":
                self.box(210,315,300,26,"침식 술사  ━━━━━━━━━",size=11)
                self.box(18,18,305,35,"전조를 읽고 이동 · 대시 · 오의 시점 판단",size=11)
        elif kind=="title":
            self.raster("title",0,0,720,405)
            self.raster("logo",34,290,325,108)
            for i,label in enumerate(["새 게임","이어하기","각성","도감","설정","종료"]):
                self.box(44,268-i*38,214,30,label,size=13)
        elif kind=="workbench":
            self.txt("준비  |  보상 → 배치 → 다음 전장 → 출전 확정",20,370,17)
            self.box(18,52,185,290,"",size=12)
            for i,t in enumerate(["상자 토큰 1 / 골드 35","보스 보상 3택1","상점 · 확장 주머니","인법서 · 조합","선택 운명 / 교환 대가"]):self.txt(t,28,310-i*47,11)
            self.box(220,52,280,290)
            for row in range(6):
                for col in range(6):
                    active=1<=row<=3 and 1<=col<=3
                    self.box(240+col*39,86+row*39,36,36,fill=colors.HexColor("#4D5C6B" if active else "#1D2A37"))
            self.txt("시작 3×3 → 주머니로 확장",237,321,11)
            self.sprite("equipment",8,280,165,35,90)
            self.sprite("equipment",12,320,205,34,49)
            self.sprite("equipment",1,359,205,34,49)
            self.box(516,52,185,290)
            for i,t in enumerate(["발동 인법 1 + 0 / 2","버퍼 0 / 6 (보존)","변경 전 / 변경 후","다음 전장: 미확정","운명 선택 ≠ 확정"]):self.txt(t,526,310-i*44,11)
            self.box(519,61,175,31,"출전 확정",fill=colors.HexColor("#604B2E"),size=13)
        elif kind=="route":
            self.txt("시작 유파와 방문 전장은 별개입니다",25,365,19)
            for i,name in enumerate(["봉마 · 공간 준비","천술 · 순서 반응","귀인 · 근접 압박","흑영 · 표식 처형"]):
                self.box(25+i*173,218,161,113,name,size=10)
                self.sprite("icons",i*3,74+i*173,278,58,43)
            self.box(25,123,670,67,"이번 전장: 미방문 전장 중 선택 · 시작 인법은 바뀌지 않음",size=13)
            self.box(495,43,200,49,"선택 확인 후 시작",fill=colors.HexColor("#604B2E"),size=14)
        elif kind=="result":
            self.txt("전장 결과",25,361,25)
            self.box(25,165,320,155,"격파 · 시간 · 이번 빌드",size=16)
            self.box(367,165,327,155,"보스 보상 → 준비 화면",size=16)
            self.box(25,70,669,60,"런 종료 때 닌자소울 정산 · 중복 지급 없음",size=15)
        elif kind=="awakening":
            self.txt("각성                 닌자소울 3",25,360,25)
            self.box(25,221,670,94,"시작 지원 선택 해금  /  비용 3소울",size=18)
            for i,t in enumerate(["체술단련","호신 부적","인법단련"]):self.box(25+i*226,95,215,94,t,size=17)
            self.txt("해금 후 새 런마다 하나 선택 · 무한 스탯 강화 없음",25,53,13)
        elif kind=="codex":
            self.txt("도감  |  적 · 인법서 · 장비",25,360,24)
            for i,t in enumerate(["침식 추격 닌자","이동진술사","봉인쇄","일본도 비전"]):self.box(25,278-i*57,218,47,t,size=14)
            self.box(263,70,431,257)
            for i,t in enumerate(["역할 / 실제 효과","어디서 얻는가","조합 재료 / 배치 조건","보스에는 어떤 예외가 있는가","대응법 / 위험 전조"]):self.txt(t,285,290-i*42,15)
        else:
            self.txt("설정",25,360,26)
            for i,t in enumerate(["음량                 ━━━━━━━","효과 강도           필수 전조는 유지","화면 흔들림       끄기 / 켜기","전체화면           끄기 / 켜기","입력 안내           키보드 · 패드 · 터치"]):self.box(25,285-i*49,670,39,t,size=14)
        self.txt("배치 설계 · 실제 런타임 캡처 아님",12,7,8,colors.HexColor("#DFCFAE"))
        c.restoreState()

    def draw(self):
        if self.kind=="atlas":
            w=(self.width-20)/3;h=(self.height-48)/3
            for i,kind in enumerate(SCREEN_NAMES):
                x=(i%3)*(w+10);y=self.height-(i//3+1)*(h+16)
                self.screen(kind,x,y,w,h)
                self.txt(f"{i+1}. {SCREEN_NAMES[kind]}",x,y+h+3,10,INK)
        elif self.kind=="flow":
            names=["시작 유파 + 첫 전장","일반 군중 · 자동3공격","엘리트 → 흔적 회수","경고 → 유파 보스","보상 · 통합 준비","다음 미방문 전장","4전장 후 최종 결속","최종 재앙 보스","결과 · 닌자소울 · 각성"]
            for i,name in enumerate(names):
                row=i//3;col=i%3;x=col*(self.width/3);y=self.height-70-row*90
                self.box(x+4,y,self.width/3-22,56,f'{i+1}. {name}',size=12)
                if col<2:self.txt("→",x+self.width/3-14,y+21,15,INK)
                elif row<2:
                    start=x+self.width/6;end=self.width/6
                    self.canv.setStrokeColor(GOLD)
                    self.canv.lines([(start,y,start,y-13),(start,y-13,end,y-13),(end,y-13,end,y-29)])
                    self.txt('↓',end-5,y-36,12,INK)
            self.txt("2~6 반복: 다음 전장은 2로 복귀. 네 전장 완료 후 7로 이동. 준비 거래는 출전 확정 전까지 임시입니다.",8,5,11,INK)
        else:self.screen(self.kind,0,0,self.width,self.height)


def styles():
    register_fonts()
    return {
        "body":ParagraphStyle("Body",fontName="NinjaGdd",fontSize=10.2,leading=16,textColor=INK,spaceAfter=9,wordWrap="CJK"),
        "h1":ParagraphStyle("H1",fontName="NinjaGddBold",fontSize=25,leading=32,textColor=NAVY,spaceAfter=16,keepWithNext=True),
        "h2":ParagraphStyle("H2",fontName="NinjaGddBold",fontSize=19,leading=26,textColor=NAVY,spaceAfter=13,keepWithNext=True),
        "h3":ParagraphStyle("H3",fontName="NinjaGddBold",fontSize=13,leading=19,textColor=NAVY,spaceBefore=8,spaceAfter=10,keepWithNext=True),
        "cell":ParagraphStyle("Cell",fontName="NinjaGdd",fontSize=9.1,leading=14,textColor=INK,wordWrap="CJK"),
        "headcell":ParagraphStyle("HeadCell",fontName="NinjaGddBold",fontSize=9.2,leading=14,textColor=CREAM,wordWrap="CJK"),
        "caption":ParagraphStyle("Caption",fontName="NinjaGdd",fontSize=9,leading=13,textColor=colors.HexColor("#63523B"),spaceAfter=8,wordWrap="CJK")}


def para(text,style):
    # Relative repository links do not survive a downloaded standalone PDF.
    text=re.sub(r'\[([^\]]+)\]\((?!https?://)([^)]+)\)',r'\1',text)
    return Paragraph(inline_markdown(text,"Courier"),style)


def parse(source: Path,st,asset_manifest,include=False):
    lines=source.read_text(encoding="utf-8").splitlines();result=[];i=0
    if include and source==SOURCES:
        i=next(n for n,line in enumerate(lines) if line.startswith('## '))
    while i<len(lines):
        line=lines[i].strip();i+=1
        if not line:continue
        if line=="<!-- PAGE -->":
            if result:result.append(CondPageBreak(300))
            continue
        if line.startswith("# "):
            if not include:result.append(para(line[2:],st["h1"]))
            continue
        if line.startswith("## "):
            if include and result and not isinstance(result[-1],PageBreak):result.extend([Spacer(1,14),CondPageBreak(150)])
            result.append(para(line[3:],st["h2"]));continue
        if line.startswith("### "):result.append(para(line[4:],st["h3"]));continue
        if line.startswith("@"):
            command,*args=line.split()
            if command=="@screen_atlas":result.append(Diagram("atlas",height=366))
            elif command=="@screen":result.append(Diagram(args[0],height=250));result.append(Spacer(1,10))
            elif command=="@flow":result.append(Diagram("flow",height=300))
            elif command in ("@include_rules","@include_packet","@sources"):
                target={"@include_rules":RULES,"@include_packet":PACKET,"@sources":SOURCES}[command]
                result.extend(parse(target,st,asset_manifest,True))
            elif command=="@asset":
                key=args[0];path=ART/(key+".png")
                if not path.exists():raise ValueError("Required image missing: "+key)
                with PILImage.open(path) as im:iw,ih=im.size
                scale=min(CW/iw,(240 if key=='vfx' else 300)/ih)
                result.append(Image(str(path),width=iw*scale,height=ih*scale))
                info=asset_manifest["assets"][key]
                result.append(para(f"{key} · {iw}×{ih} · {info['state']} · {info['inspection_note']}",st["caption"]))
            else:raise ValueError("Unknown directive: "+line)
            continue
        if line.startswith("|"):
            rows=[line]
            while i<len(lines) and lines[i].strip().startswith("|"):
                rows.append(lines[i].strip());i+=1
            rows=[r for r in rows if not re.fullmatch(r"[|\s:\-]+",r)]
            data=[]
            for n,row in enumerate(rows):data.append([para(cell.strip(),st["headcell" if n==0 else "cell"]) for cell in row.strip("|").split("|")])
            count=len(data[0])
            if any(len(row)!=count for row in data):raise ValueError("Ragged table in "+str(source))
            widths=[CW/count]*count
            if count==3:widths=[CW*.23,CW*.45,CW*.32]
            if count==4:widths=[CW*.20,CW*.25,CW*.30,CW*.25]
            table=Table(data,colWidths=widths,repeatRows=1,hAlign="LEFT")
            table.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,0),NAVY),("ROWBACKGROUNDS",(0,1),(-1,-1),[colors.HexColor("#FFFDFA"),colors.HexColor("#ECE9E1")]),("VALIGN",(0,0),(-1,-1),"TOP"),("LEFTPADDING",(0,0),(-1,-1),8),("RIGHTPADDING",(0,0),(-1,-1),8),("TOPPADDING",(0,0),(-1,-1),7),("BOTTOMPADDING",(0,0),(-1,-1),7),("LINEBELOW",(0,0),(-1,0),1,GOLD)]))
            result.extend([table,Spacer(1,12)]);continue
        if line.startswith("<!--"):continue
        if line.startswith("```"):continue
        if line.startswith("> "):line=line[2:]
        if line.startswith("- "):line="• "+line[2:]
        result.append(para(line,st["body"]))
    while result and isinstance(result[-1],PageBreak):result.pop()
    return result


def decorate(c,doc):
    c.saveState();c.setFillColor(CREAM);c.rect(0,0,W,H,fill=1,stroke=0)
    c.setFillColor(NAVY);c.rect(0,H-33,W,33,fill=1,stroke=0)
    c.setFillColor(CREAM);c.setFont("NinjaGddBold",10);c.drawString(44,H-22,"닌자의 신  /  HUMAN BLUEPRINT")
    c.setFont("NinjaGdd",8);c.drawRightString(W-44,H-22,"2026.09.11 · 설계 / 자산 후보 검토본")
    c.setStrokeColor(GOLD);c.line(44,33,W-44,33)
    c.setFillColor(INK);c.setFont("NinjaGdd",8);c.drawString(44,20,"새 설계와 실제 구현을 구분합니다 · 최종 승인 전 게임 변경 없음")
    c.drawRightString(W-44,20,str(doc.page));c.restoreState()


class BlueprintDoc(SimpleDocTemplate):
    def afterFlowable(self,flowable):
        if isinstance(flowable,Paragraph) and flowable.style.name in ("H1","H2"):
            title=flowable.getPlainText();key=f"section-{self.seq.nextf('section')}"
            self.canv.bookmarkPage(key);self.canv.addOutlineEntry(title,key,level=0)


def build(output=OUTPUT,manifest_path=MANIFEST):
    asset_path=ART/"manifest.json"
    assets=json.loads(asset_path.read_text(encoding="utf-8"))
    for key,item in assets["assets"].items():
        if sha(ART/item["file"])!=item["sha256"]:raise ValueError("Asset hash changed: "+key)
    st=styles();story=parse(BOOK,st,assets)
    output.parent.mkdir(parents=True,exist_ok=True)
    doc=BlueprintDoc(str(output),pagesize=(W,H),leftMargin=44,rightMargin=44,topMargin=52,bottomMargin=48,title="닌자의 신 — 사람용 블루프린트",author="Ninja Survival project",invariant=1)
    doc.build(story,onFirstPage=decorate,onLaterPages=decorate)
    reader=PdfReader(output);texts=[p.extract_text() or "" for p in reader.pages]
    required=["상세 SWOT","자동","각성","schema 2","봉마","천술","귀인","흑영","P08"]
    for token in required:
        if token not in "\n".join(texts):raise ValueError("Missing PDF content: "+token)
    for n,text in enumerate(texts,1):
        if len(text.strip())<85:raise ValueError(f"Unexpected near-blank page {n}")
    inputs=[BOOK,RULES,PACKET,SOURCES,asset_path,ART/'provenance.json',ART/'motion/contract.json',Path(__file__)]
    manifest={"document_id":"NS-HUMAN-BLUEPRINT","status":"REVIEW_CANDIDATE_NOT_IMPLEMENTATION_PASS","pdf":str(output.relative_to(ROOT)) if output.is_relative_to(ROOT) else str(output),"pdf_sha256":sha(output),"page_count":len(texts),"sources":[{"path":str(p.relative_to(ROOT)),"sha256":sha(p)} for p in inputs],"asset_count":len(assets["assets"]),"runtime":"NOT_RUN","human":"NOT_RUN","user_approval":"PENDING"}
    manifest_path.parent.mkdir(parents=True,exist_ok=True)
    manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8",newline="\n")
    print(json.dumps({"pdf":str(output),"pages":len(texts),"sha256":manifest["pdf_sha256"]},ensure_ascii=False))
    return manifest


if __name__=="__main__":
    parser=argparse.ArgumentParser();parser.add_argument("--output",type=Path,default=OUTPUT);parser.add_argument("--manifest",type=Path,default=MANIFEST);a=parser.parse_args();build(a.output,a.manifest)
