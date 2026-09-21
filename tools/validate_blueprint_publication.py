"""Verify publication binding and create disposable PDF-page contact sheets for review."""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
import pdfplumber
from pypdf import PdfReader
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.utils import ImageReader
from export_replanned_blueprint_pdf import ROOT,OUTPUT,MANIFEST,ART,register_fonts

def run():
    manifest=json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert hashlib.sha256(OUTPUT.read_bytes()).hexdigest()==manifest["pdf_sha256"]
    for entry in manifest["sources"]:
        assert hashlib.sha256((ROOT/entry["path"]).read_bytes()).hexdigest()==entry["sha256"],entry["path"]
    reader=PdfReader(OUTPUT);assert len(reader.pages)==manifest["page_count"]
    texts=[p.extract_text() or "" for p in reader.pages]
    for token in ["상세 SWOT","강점","약점","기회","위협","SO","WO","ST","WT","도감","설정","무적","3×3","2.5초","schema 2","96","Vampire","Aseprite"]:
        assert token in "\n".join(texts),token
    assert not any("@asset" in t or "@screen" in t or "@include" in t for t in texts)
    with pdfplumber.open(OUTPUT) as pdf:
        out=[]
        for n,p in enumerate(pdf.pages,1):
            for ch in p.chars:
                if ch["text"].strip() and (ch["x0"]<-.5 or ch["x1"]>p.width+.5 or ch["top"]<-.5 or ch["bottom"]>p.height+.5):out.append((n,ch["text"]))
        assert not out,out[:10]
    assets=json.loads((ART/"manifest.json").read_text(encoding="utf-8"))
    for key,a in assets["assets"].items():
        assert (ROOT/a["consumer"]).exists(),(key,a["consumer"])
        assert a["approval"]=="PENDING"
        if a["alpha_required"]:assert a["alpha_channel_check"]=="PASS",key
        assert not any(a['measured_cut_occupied_pixels']),('cut boundary',key)
        assert hashlib.sha256((ART/a['file']).read_bytes()).hexdigest()==a['sha256'],key
        assert len(a["regions"])==a["grid"][0]*a["grid"][1]
        for region in a["regions"]:
            x,y,w,h=region["rect"];assert min(x,y)>=0 and min(w,h)>0 and x+w<=a["width"] and y+h<=a["height"]
    print(json.dumps({"publication_hashes":"PASS","pages":len(texts),"required_content":"PASS","page_character_bounds":"PASS","asset_alpha_and_region_bounds":"PASS","occupied_cut_alpha_threshold":32,"asset_continuity":"NOT_RUN","runtime":"NOT_RUN"}))
    return texts

def contacts(texts):
    directory=ROOT/"tmp/pdfs/blueprint-review";files=sorted(directory.glob("page-*.png"))
    assert len(files)==len(texts),(len(files),len(texts))
    register_fonts();c=Canvas(str(directory/"contacts.pdf"),pagesize=(1500,1120),invariant=1)
    for index,path in enumerate(files):
        slot=index%12;col=slot%3;row=slot//3;x=col*500+12;y=1120-(row+1)*280+18
        c.drawImage(str(path),x,y,width=476,height=250,preserveAspectRatio=True,anchor="c")
        c.setFont("NinjaGdd",10);c.drawString(x,y+253,f"{index+1:02d}  "+texts[index].splitlines()[2][:42])
        if slot==11:c.showPage()
    if len(files)%12:c.showPage()
    c.save()
    (directory/"page-index.json").write_text(json.dumps([{ "page":n+1,"text":t} for n,t in enumerate(texts)],ensure_ascii=False,indent=2),encoding="utf-8")

if __name__=="__main__":contacts(run())
