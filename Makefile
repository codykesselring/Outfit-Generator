# Variables
APP_NAME=outfit-generator
VERSION=1.0.0
DEB_PACKAGE=$(APP_NAME)-$(VERSION).deb
TEMP_DIR=temp
INSTALL_DIR=/usr/share/$(APP_NAME)
BIN_DIR=/usr/bin

.PHONY: build-deb

# Source files
MAIN_SCRIPT=main.py
ICON_FILE=assets/icon.png  # You might want to add an icon later
DESKTOP_FILE=assets/$(APP_NAME).desktop  # Desktop entry file

build:
	@echo "Python application doesn't need compilation"

test:
	pip install pytest pillow
	python3 -m pytest tests.py -v

clean:
	@echo "Cleaning up..."
	rm -rf $(TEMP_DIR)
	rm -rf __pycache__
	rm -rf *.pyc

vclean: clean
	rm -rf $(TEMP_DIR) $(DEB_PACKAGE)
	rm -f $(DEB_PACKAGE)

run: build
	@echo "Running outfit generator..."
	python3 $(MAIN_SCRIPT)

lint:
	@echo "Linting Python files..."
	flake8 $(MAIN_SCRIPT) tests.py
	pylint $(MAIN_SCRIPT) tests.py

build-deb:
	@echo "Starting deb package build..."
	
	# Create directory structure
	@mkdir -p $(TEMP_DIR)$(INSTALL_DIR)/clothes
	@mkdir -p $(TEMP_DIR)$(BIN_DIR)
	@mkdir -p $(TEMP_DIR)/DEBIAN
	
	# Copy main files
	@echo "Copying main files..."
	@cp -v main.py $(TEMP_DIR)$(INSTALL_DIR)/
	@cp -v base_image.png $(TEMP_DIR)$(INSTALL_DIR)/
	
	# Copy clothes in batches (safer for many files)
	@echo "Copying clothes (this may take a while)..."
	@find clothes/ -type f -exec cp -v --parents {} $(TEMP_DIR)$(INSTALL_DIR)/ \;
	
	# Create launcher
	@echo '#!/bin/sh' > $(TEMP_DIR)$(BIN_DIR)/$(APP_NAME)
	@echo 'cd $(INSTALL_DIR) && python3 main.py' >> $(TEMP_DIR)$(BIN_DIR)/$(APP_NAME)
	@chmod -v +x $(TEMP_DIR)$(BIN_DIR)/$(APP_NAME)
	
	# Create control file
	@echo "Package: $(APP_NAME)" > $(TEMP_DIR)/DEBIAN/control
	@echo "Version: $(VERSION)" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Section: graphics" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Priority: optional" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Architecture: all" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Depends: python3, python3-pil, python3-tk" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Maintainer: Your Name <your.email@example.com>" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Description: Outfit Generator Application" >> $(TEMP_DIR)/DEBIAN/control
	@echo " A GUI application for mixing and matching clothing items." >> $(TEMP_DIR)/DEBIAN/control
	
	# Build package with simple status message
	@echo "Building package (please be patient, this may take several minutes)..."
	@if ! dpkg-deb --root-owner-group --build $(TEMP_DIR) $(DEB_PACKAGE); then \
		echo "Package build failed"; \
		exit 1; \
	fi
	
	@echo "Package successfully built: $(DEB_PACKAGE)"
	@du -sh $(DEB_PACKAGE)
	
lint-deb:
	@echo "Linting deb package..."
	-lintian $(DEB_PACKAGE)

install:
	@echo "Installing package..."
	sudo dpkg -i $(DEB_PACKAGE)

uninstall:
	@echo "Uninstalling package..."
	sudo dpkg -r $(APP_NAME)

.PHONY: build test clean vclean run lint build-deb lint-deb install uninstall
