VERSION = 1.0.0
VENV_PATH = ./venv
VENV = . $(VENV_PATH)/bin/activate;

.PHONY: test
test:
	$(VENV) pytest tests/*.py

.PHONY: build
build:
	echo "$(VERSION)" > .version
	$(VENV) python -m build

.PHONY: install
install: build
	$(VENV) pip3 install .

.PHONY: install-system
install-system: build
	pip3 install .

.PHONY: lint
lint:
	$(VENV) pylint $(SRC)
	$(VENV) ruff $(SRC)

configure: requirements.txt
	rm -rf $(VENV_PATH)
	make $(VENV_PATH)

$(VENV_PATH):
	python3.11 -m venv $(VENV_PATH)
	$(VENV) pip install -r requirements.txt
