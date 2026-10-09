# trishuli-flood-response

Satellite-based flood damage assessment: Sentinel-1/2 + Copernicus DEM + **pre-event** OSM,
config-driven so it runs for any AOI/date.

Case study: Bhote Koshi → Trishuli flash flood (ice-rock avalanche / GLOF), 26 Aug 2026, Rasuwa/Nuwakot/Dhading, Nepal.
Evaluation-only reference: Copernicus EMS EMSR927 (never used as input).

## Quick start (Day 1)

```bash
micromamba create -n flood -f environment.yml && micromamba activate flood
cp .env.example .env          # add free CDSE credentials (https://dataspace.copernicus.eu)
make test
make plan                     # picks scenes, prints sizes, writes data/raw/manifest.json (no credentials needed)
make ingest                   # downloads S1, S2, DEM, OSM into data/raw/
```

`make plan` is the important first step: it shows which same-orbit-track S1 pair and which S2 tiles
will be used, and the total download size, before you spend bandwidth.

## Layout

| Path | Purpose |
|---|---|
| `config/aoi_*.yaml` | AOI, event date, windows, thresholds (the only thing that changes between AOIs) |
| `src/cdse.py` | CDSE OData search + resumable authenticated download |
| `src/pairing.py` | Same-relative-orbit + same-direction S1 pair selection; S2 pre/post per tile |
| `src/dem.py` | Copernicus DEM GLO-30 from AWS Open Data (anonymous) |
| `src/osm.py` | Pre-event OSM via ohsome (tiled, de-duplicated) → GeoPackage |
| `src/ingest.py` | CLI tying the above together (`--dry-run`, `--skip-s1/s2/dem/osm`) |
| `tests/` | Offline tests for selection logic |

## Changes from the original 7-day plan

- **`sentinelsat` replaced** by a small CDSE OData client: sentinelsat targets the retired SciHub, not CDSE.
- **`--dry-run` / manifest**: scene selection is inspectable and reproducible before any download.
- **AOI tightened** from ~140×100 km to the flood corridor (fewer tiles, far smaller downloads). Refine when judges give the AOI.
- **Event-time safety**: a same-day S1 pass is not treated as "post-event" unless `event_time_utc` is set.
- **Pair ranking**: post as early as possible after the event, then pre as close as possible; alternatives are logged for the Q&A on "what if no same-orbit pair?".
- **Cloud-limited S2 is allowed with a flag**, not a hard failure (monsoon).
- **OSM tiling + dedup**, and a hard check that `osm_snapshot < event_date`.

## Attribution

Contains modified Copernicus Sentinel data 2026. Copernicus DEM © DLR e.V. 2010–2014 and © Airbus Defence and Space GmbH 2014–2018, provided under COPERNICUS by the EU and ESA.
© OpenStreetMap contributors (ODbL). Training data: Kuro Siwo (Bountos et al., NeurIPS 2024, MIT); Sen1Floods11 (Bonafilia et al., CVPR-W 2020, CC BY 4.0).
Evaluation reference only: Copernicus EMS EMSR927.
