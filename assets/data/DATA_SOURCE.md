# Quran data — provenance & integrity

**Do not hand-edit `quran.json`.** The Arabic text must come from a verified
source; it was not typed by hand.

## Files
- `quran.json` — full Uthmani text, all 114 surahs / 6236 ayahs.
  App schema: `{ "surahs": [ { number, name, englishName, revelationType,
  ayahCount, ayahs: [ { number, text } ] } ] }`.
- `surahs.json` — slim metadata for all 114 surahs (for fast list screens):
  `{ number, name, englishName, revelationType, ayahCount, startJuz }`.
- `juz.json` — the 30 juz boundaries (standard Hafs division):
  `{ number, name, startSurah, startAyah, endSurah, endAyah }`.

## Source
- Arabic text + surah metadata: **risan/quran-json** (npm `quran-json@3.1.2`,
  MIT-licensed; text traces to the Tanzil project). Only key names were
  renamed into the app schema — no character of Arabic text was modified.
- Juz boundaries: standard Hafs `juz` start points (canonical reference data),
  end points computed as the ayah preceding the next juz's start.

## Integrity checks performed at generation
- surah ids are exactly 1..114
- every surah's `ayahs.length == ayahCount`
- ayah numbers are contiguous 1..ayahCount
- total ayahs == 6236
- juz count == 30; Juz 29 starts 67:1 (تبارك), Juz 30 starts 78:1 (عمّ)

## To regenerate / update
Re-run the transform against the npm package:
```bash
npm pack quran-json          # -> quran-json-<v>.tgz
tar xzf quran-json-*.tgz     # -> package/dist/quran.json
# then run the transform used to produce these files (rename keys +
# attach juz boundaries) and re-verify the integrity assertions above.
```
