VENV_PATH = ./venv
VENV = . $(VENV_PATH)/bin/activate;
ROOT_VENV = . .$(VENV_PATH)/bin/activate;

COMMON_DIR = myrtio
COMMON_PACKGE = $(COMMON_DIR)/myrtio
COMMON_VERSION = 1.0.2

UDP_TRANSPORT_DIR = myrtio-udp
UDP_TRANSPORT_PACKAGE = $(UDP_TRANSPORT_DIR)/myrtio_udp
UDP_TRANSPORT_VERSION = 1.0.0

define build-package
	echo "$(2)" > "$(1)/.version"
	cd $(1); $(ROOT_VENV) python -m build
	cd $(1); pip install .
endef

define test-package
	cd $(1); $(ROOT_VENV) pytest
endef

define clean-package
	rm -rf "$(1)"/*.egg-info
	rm -rf "$(1)/build"
	rm -rf "$(1)/dist"
	rm -f "$(1)/.version"
endef

define publish-package
	git add Makefile
	git commit -m "chore: release $(1) $(2)"
	cd $(1); $(ROOT_VENV) python -m twine upload --repository pypi dist/*
endef

.PHONY: clean
clean:
	$(call clean-package,$(COMMON_DIR))
	$(call clean-package,$(UDP_TRANSPORT_DIR))

.PHONY: test
test:
	$(call test-package,$(COMMON_DIR))

.PHONY: build
build:
	$(call build-package,$(COMMON_DIR),$(COMMON_VERSION))
	$(call build-package,$(UDP_TRANSPORT_DIR),$(UDP_TRANSPORT_VERSION))

.PHONY: lint
lint:
	$(VENV) pylint \
		"$(UDP_TRANSPORT_PACKAGE)" \
		"$(COMMON_PACKGE)"
	$(VENV) ruff check \
		"$(UDP_TRANSPORT_PACKAGE)" \
		"$(COMMON_PACKGE)"

.PHONY: publish-common
publish-common:
	$(call publish-package,$(COMMON_DIR),$(COMMON_VERSION))

.PHONY: publish-udp
publish-udp:
	$(call publish-package,$(UDP_TRANSPORT_DIR),$(UDP_TRANSPORT_VERSION))

configure: requirements.txt
	rm -rf $(VENV_PATH)
	make $(VENV_PATH)

$(VENV_PATH):
	python3.11 -m venv $(VENV_PATH)
	$(VENV) pip install -r requirements.txt