#Variables
APP_NAME=outfit-generator
DEB_PACKAGE=$(APP_NAME)-v1.0.0.deb
TEMP_DIR=temp
PYTHON=python3
PIP=pip3

# Main targets
build:
	@echo "Python application doesn't need compilation"

test:
	sudo apt update
	sudo apt install -y python3 python3-pip python3-tk python3-pil.imagetk
	$(PIP) install pillow pytest flake8
	$(PIP) install --upgrade pillow
	$(PYTHON) -m pytest tests.py

run:
	sudo apt update
	sudo apt install -y python3 python3-pip python3-tk python3-pil.imagetk
	$(PIP) install pillow pytest flake8
	$(PIP) install --upgrade pillow
	$(PYTHON) main.py

clean:
	@echo "Cleaning up..."
	rm -rf $(TEMP_DIR)
	rm -rf __pycache__
	rm -rf */__pycache__
	rm -f *.deb

# Packaging targets
build-deb:
	@echo "Building Debian package..."
	mkdir -p $(TEMP_DIR)/DEBIAN
	mkdir -p $(TEMP_DIR)/usr/bin
	mkdir -p $(TEMP_DIR)/usr/share/$(APP_NAME)
	mkdir -p $(TEMP_DIR)/usr/share/$(APP_NAME)/clothes
	
	# Create control file
	@echo "Package: $(APP_NAME)" > $(TEMP_DIR)/DEBIAN/control
	@echo "Version: 1.0.0" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Architecture: all" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Maintainer: Your Name <your.email@example.com>" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Description: Outfit Generator Application" >> $(TEMP_DIR)/DEBIAN/control
	
	# Copy files
	cp main.py $(TEMP_DIR)/usr/bin/$(APP_NAME)
	chmod +x $(TEMP_DIR)/usr/bin/$(APP_NAME)
	cp -r clothes $(TEMP_DIR)/usr/share/$(APP_NAME)/
	cp base_image.png $(TEMP_DIR)/usr/share/$(APP_NAME)/
	
	# Build package
	dpkg-deb --build --root-owner-group $(TEMP_DIR) $(DEB_PACKAGE)

lint:
	-lintian $(DEB_PACKAGE)

install:
	sudo dpkg -i $(DEB_PACKAGE)

uninstall:
	sudo dpkg -r $(APP_NAME)

# Docker targets
docker-image:
	docker build -t $(APP_NAME):latest .

docker-run:
	docker run -it --rm \
		-v $(PWD)/clothes:/app/clothes \
		-v $(PWD)/base_image.png:/app/base_image.png \
		$(APP_NAME):latest

.PHONY: build test run clean build-deb lint install uninstall docker-image docker-run
