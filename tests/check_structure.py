from pathlib import Path
root=Path(__file__).resolve().parents[1]/"Addon"/"WarriorCompanion"
toc=(root/"WarriorCompanion.toc").read_text()
files=[x.strip() for x in toc.splitlines() if x.strip() and not x.startswith("#")]
assert files and len(files)==len(set(files))
assert all((root/x).is_file() for x in files), files
print("OK: " + str(len(files)) + " fichiers declares et presents")
