SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
export PATH := $(CURDIR)/.venv/bin:$(PATH)

.PHONY: help venv lock functional check wheel clean

help: ## Show available targets
	@grep -hE '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk -F':.*?## ' '{printf "  %-12s %s\n", $$1, $$2}'

venv: ## Hash-locked environment, with this checkout installed editable
	python3 -m venv .venv
	.venv/bin/pip install --quiet --require-hashes -r tests/requirements.lock
	.venv/bin/pip install --quiet --no-deps -e .

lock: ## Pin tests/requirements.txt, with hashes
	.venv/bin/pubkit lock

functional: ## The Gherkin suite
	cd tests && pytest -q

check: functional ## Everything CI runs

wheel: ## Build the wheel a release carries
	.venv/bin/pip wheel --quiet --no-deps . -w dist

clean: ## Remove build artifacts
	rm -rf build dist src/*.egg-info .pytest_cache tests/.pytest_cache
