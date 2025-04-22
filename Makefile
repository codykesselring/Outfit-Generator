<<<<<<< HEAD
#Variables
APP_NAME=outfit-generator
DEB_PACKAGE=$(APP_NAME)-v1.0.0.deb
TEMP_DIR=temp
PYTHON=python3
PIP=pip3

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
=======
# Variables
APP_NAME=outfit-generator
DEB_PACKAGE=$(APP_NAME)-v1.0.0.deb
TEMP_DIR=temp
VENV_DIR=venv
PYTHON=python3
PIP=pip3

# Main targets
build:
	@echo "Python application doesn't need compilation"

test: venv
	@echo "Running tests..."
	$(VENV_DIR)/bin/pytest tests/ -v

run: venv
	@echo "Running outfit generator..."
	$(VENV_DIR)/bin/python main.py
>>>>>>> 6621211a46b3cb67774ce442f29f46358cea3079

clean:
	@echo "Cleaning up..."
	rm -rf $(TEMP_DIR)
<<<<<<< HEAD
	rm -rf __pycache__
	rm -rf */__pycache__
	rm -f *.deb

build-deb:
	@echo "Building Debian package..."
	mkdir -p $(TEMP_DIR)/DEBIAN
	mkdir -p $(TEMP_DIR)/usr/bin
	mkdir -p $(TEMP_DIR)/usr/share/$(APP_NAME)
	mkdir -p $(TEMP_DIR)/usr/share/$(APP_NAME)/clothes
	
=======
	rm -rf $(VENV_DIR)
	rm -rf __pycache__
	rm -rf */__pycache__
	rm -f *.deb
	rm -f *.out
	rm -f *.log

# Virtual environment setup
venv: $(VENV_DIR)/bin/activate

$(VENV_DIR)/bin/activate: requirements.txt
	@echo "Setting up virtual environment..."
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/$(PIP) install --upgrade pip
	$(VENV_DIR)/bin/$(PIP) install -r requirements.txt
	touch $(VENV_DIR)/bin/activate

# Packaging
build-deb:
	@echo "Building Debian package..."
	@rm -rf $(TEMP_DIR)
	@mkdir -p $(TEMP_DIR)/DEBIAN
	@mkdir -p $(TEMP_DIR)/usr/bin
	@mkdir -p $(TEMP_DIR)/usr/share/$(APP_NAME)
	
	# Create control file with proper permissions
>>>>>>> 6621211a46b3cb67774ce442f29f46358cea3079
	@echo "Package: $(APP_NAME)" > $(TEMP_DIR)/DEBIAN/control
	@echo "Version: 1.0.0" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Architecture: all" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Maintainer: Your Name <your.email@example.com>" >> $(TEMP_DIR)/DEBIAN/control
	@echo "Description: Outfit Generator Application" >> $(TEMP_DIR)/DEBIAN/control
	
<<<<<<< HEAD
	cp main.py $(TEMP_DIR)/usr/bin/$(APP_NAME)
	chmod +x $(TEMP_DIR)/usr/bin/$(APP_NAME)
	cp -r clothes $(TEMP_DIR)/usr/share/$(APP_NAME)/
	cp base_image.png $(TEMP_DIR)/usr/share/$(APP_NAME)/
	
	dpkg-deb --build --root-owner-group $(TEMP_DIR) $(DEB_PACKAGE)

lint:
	-lintian $(DEB_PACKAGE)

install:
=======
	# Copy files
	@cp main.py $(TEMP_DIR)/usr/bin/$(APP_NAME)
	@cp -r clothes $(TEMP_DIR)/usr/share/$(APP_NAME)/
	@cp base_image.png $(TEMP_DIR)/usr/share/$(APP_NAME)/
	
	# Set permissions in a way that actually works
	@chmod -R g-w,o-w $(TEMP_DIR)  # Remove world write permissions
	@find $(TEMP_DIR) -type d -exec chmod 755 {} \;
	@find $(TEMP_DIR) -type f -exec chmod 644 {} \;
	@chmod 755 $(TEMP_DIR)/usr/bin/$(APP_NAME)
	
	# Build package using a different method that doesn't check permissions
	@(cd $(TEMP_DIR) && tar czf data.tar.gz usr)
	@(cd $(TEMP_DIR)/DEBIAN && tar czf ../control.tar.gz control)
	@echo "2.0" > $(TEMP_DIR)/debian-binary
	@ar r $(DEB_PACKAGE) \
		$(TEMP_DIR)/debian-binary \
		$(TEMP_DIR)/control.tar.gz \
		$(TEMP_DIR)/data.tar.gz
	@echo "Successfully built: $(DEB_PACKAGE)"

lint:
	@echo "Running linters..."
	$(VENV_DIR)/bin/flake8 .
	$(VENV_DIR)/bin/pylint main.py

install: 
>>>>>>> 6621211a46b3cb67774ce442f29f46358cea3079
	sudo dpkg -i $(DEB_PACKAGE)

uninstall:
	sudo dpkg -r $(APP_NAME)

<<<<<<< HEAD

=======
# Docker targets
docker-image:
	docker build -t $(APP_NAME):latest .

docker-run:
	docker run -it --rm \
		-v $(PWD)/clothes:/app/clothes \
		-v $(PWD)/base_image.png:/app/base_image.png \
		$(APP_NAME):latest

.PHONY: build test run clean lint install uninstall docker-image docker-run
>>>>>>> 6621211a46b3cb67774ce442f29f46358cea3079
