"""Validation des textures TGA originales présentes dans le paquet WoW."""
from pathlib import Path
import struct

root = Path(__file__).resolve().parents[1] / "Addon" / "WarriorCompanion" / "Textures"
expected = {"HordeSky.tga": (256,128), "Warcrest.tga": (128,128), "AdviceArt.tga": (256,128), "HeaderPlate.tga": (512,128)}
for name, (width, height) in expected.items():
    data=(root / name).read_bytes()
    assert len(data)==18+width*height*4, f"{name}: taille"
    assert data[2]==2 and data[16]==32, f"{name}: TGA non compresse BGRA32"
    assert struct.unpack_from("<HH",data,12)==(width,height), f"{name}: dimensions"
    assert data[17]==40, f"{name}: orientation haut-gauche + 8 bits alpha"
    assert any(data[i]!=0 for i in range(21,len(data),4)), f"{name}: image vide"
    print(f"OK: {name} ({width}x{height}, TGA 32 bits)")
