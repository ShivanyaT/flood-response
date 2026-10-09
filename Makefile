CONFIG ?= config/aoi_trishuli.yaml

.PHONY: plan ingest test lint
plan:      ## select scenes + write data/raw/manifest.json, download nothing
	python -m src.ingest --config $(CONFIG) --dry-run
ingest:    ## download S1, S2, DEM, OSM into data/raw/
	python -m src.ingest --config $(CONFIG)
test:
	pytest -q
lint:
	ruff check src tests
# make train / infer / dashboard / report are added on later days
