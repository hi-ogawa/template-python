SHELL := /bin/bash
PYTHON ?= poetry run python
YTT ?= docker run --rm -i gerritk/ytt:v0.35.1
PRETTIER ?= docker run --rm -v $(PWD):/work tmknom/prettier:2.0.5
SAFETY ?= docker run -i --rm pyupio/safety:latest safety

lint:
	$(PYTHON) -m black .
	$(PYTHON) -m isort .
	$(PRETTIER) --write .

lint-check:
	$(PYTHON) -m black --check --diff .
	$(PYTHON) -m isort --check --diff .
	$(PYTHON) -m pylint src tests
	$(PRETTIER) --check .

mypy:
	$(PYTHON) -m mypy .

test:
	$(PYTHON) -m pytest $(options)

# Hit F5 in vscode after `make test-debugpy`
test-debugpy:
	$(PYTHON) -m pytest -p tests.plugin_debugpy $(options)

test-cov:
	$(PYTHON) -m pytest --cov=src $(options)

test-cov-view:
	$(PYTHON) -m http.server -d htmlcov

safety:
	poetry export --dev | $(SAFETY) check --stdin

ytt:
	$(YTT) -f - < .github/workflows-ytt/ci.yml > .github/workflows/ci.yml

ytt-check:
	diff <($(YTT) -f - < .github/workflows-ytt/ci.yml) .github/workflows/ci.yml

# Auto generate phony targets (cf. https://github.com/tmknom/prettier/blob/35d2587ec052e880d73f73547f1ffc2b11e29597/Makefile#L4)
.PHONY: $(shell grep --no-filename -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/:.*//')
