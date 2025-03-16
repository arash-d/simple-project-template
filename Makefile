SHELL := /bin/bash
PACKAGES := $(wildcard project-*)
VENV := .venv
PROJECT_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PACKAGE_SUFFIX := project-
PYPROJECT_DOT_TOML := pyproject.toml

.PHONY: venv create build build-all clean

# Create Virtual Environment
venv:
	@echo "Creating virtual environment..."
	uv venv $(VENV)



# Build all packages
build-all: venv
	@echo "Starting loop test..."
	@for pkg in $(PACKAGES); do \
        echo "Building $$pkg..."; \
        pkg_normalized=$$(echo $$pkg | sed 's/-/_/g'); \
		echo "Build $$pkg .whl at $(PROJECT_ROOT)/dist/"; \
		uv build $(PROJECT_ROOT)/$$pkg -o $(PROJECT_ROOT)/dist/; \
		WHL_PATH=$$(ls $(PROJECT_ROOT)/dist/$$pkg_normalized*.whl | grep $$pkg_normalized ); \
		if [ -n "$$WHL_PATH" ]; then \
			echo "Installing $$pkg..."; \
			uv pip install "$$WHL_PATH"; \
			echo "Installing $$pkg in editable (-e) mode to reflect changes instantly..."; \
			uv pip install -e $(PROJECT_ROOT)/$$pkg; \
		else \
			echo "No .whl file found for $$pkg"; \
		fi \
    done
		


# Build a specific package (Usage: make build package=<packagename>)
build: venv
	@package=$(if $(package),$(package),$(word 2, $(MAKECMDGOALS)))
	@if [ -z "$$package" ]; then \
		echo "Error: package is required! Example: make $(MAKECMDGOALS) package=foo"; \
		exit 1; \
	fi
	@echo "Building $(PACKAGE_SUFFIX)$(package)..."
	@ls -ld "$(PROJECT_ROOT)/$(PACKAGE_SUFFIX)$(package)" > /dev/null 2>&1 || echo "Package $(PACKAGE_SUFFIX)$(package) not found"

	@echo "Building $(PROJECT_ROOT)/$(PACKAGE_SUFFIX)$(package)..."
	@cd $(PROJECT_ROOT)/$(PACKAGE_SUFFIX)$(package) && uv build

	@echo "Installing $(PACKAGE_SUFFIX)$(package)..."; \

	@WHL_PATH=$$(ls $(PROJECT_ROOT)/dist/$(subst -,_,$(PACKAGE_SUFFIX)$(package))*.whl  | head -n 1); \
	if [ -n "$$WHL_PATH" ]; then \
		echo "Found: $$WHL_PATH"; \
		uv pip install "$$WHL_PATH"; \
		echo "Installing in editable (-e) mode to reflect changes instantly..."; \
		uv pip install -e $(PROJECT_ROOT)/$(PACKAGE_SUFFIX)$(package); \
		echo "Build and install complete"; \
	else \
		echo "No .whl file found for $(PACKAGE_SUFFIX)$(package)"; \
		exit 1; \
	fi


# Create a package with uv (Usage: make create package=<packagename>)
create:
	@package=$(if $(package),$(package),$(word 2, $(MAKECMDGOALS)))
	@if [ -z "$$package" ]; then \
		echo "Error: package is required! Example: make $(MAKECMDGOALS) package=foo"; \
		exit 1; \
	fi
	@echo "Creating package: $(PACKAGE_SUFFIX)$(package)..."

	@cd $(PROJECT_ROOT) && uv init --lib $(PACKAGE_SUFFIX)$(package)
	@echo "Package $(PACKAGE_SUFFIX)$(package) initialized!"

	@echo "Updating $(PYPROJECT_DOT_TOML)..."
	@echo -e '\n[tool.setuptools.packages.find]\nwhere = ["src"]' >> $(PROJECT_ROOT)/$(PACKAGE_SUFFIX)$(package)/$(PYPROJECT_DOT_TOML)
	@echo "$(PYPROJECT_DOT_TOML) updated!"

	@echo "Package $(PACKAGE_NAME) setup complete!"



# Clean - Uninstall all packages and remove generated files
clean:
	@echo "Cleaning up..."
	@if [[ -n "$$(uv pip list --format=freeze)" ]]; then \
		uv pip list --format=freeze | cut -d= -f1 | xargs -r -I {} uv pip uninstall -- {}; \
	else \
		echo "No installed packages to remove."; \
	fi
	@find . \
		-type d \
		\( \
			-name "__pycache__" \
			-o -name "*.egg-info" \
			-o -name "dist" \
			-o -name "build" \
			-o -name ".pytest_cache" \
			-o -name $(VENV) \
		\) \
		-exec rm -rf {} +
	@echo "Cleanup complete!"
