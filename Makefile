FORGE_VERSION = 1.14.3-27.0.60
TWEAKED_VERSION = 1.14.3-1.83.1

SRC_DIR = src
FORGE_INST_JAR_NAME = forge-$(FORGE_VERSION)-installer.jar
FORGE_INST_URL = https://files.minecraftforge.net/maven/net/minecraftforge/forge/$(FORGE_VERSION)/$(FORGE_INST_JAR_NAME)
FORGE_INST_JAR_PATH = $(SRC_DIR)/$(FORGE_INST_JAR_NAME)

FORGE_SERVER_JAR_NAME = forge-$(FORGE_VERSION).jar 

TWEAKED_JAR_NAME = cc-tweaked-$(TWEAKED_VERSION).jar
TWEAKED_URL = https://media.forgecdn.net/files/2730/582/$(TWEAKED_JAR_NAME)
TWEAKED_JAR_PATH = server/mods/$(TWEAKED_JAR_NAME)

EULA = server/eula.txt

README_CLIENT = README_CLIENT.md

START_SH = server/start.sh

$(FORGE_INST_JAR_PATH):
	mkdir -p $(SRC_DIR)
	cd $(SRC_DIR) && curl -O $(FORGE_INST_URL)

.PHONY: install-server
install-server: $(FORGE_INST_JAR_PATH)
	mkdir -p server
	cd server && java -Xmx2G -jar ../$(FORGE_INST_JAR_PATH) --installServer

server: install-server

$(EULA): server
	echo 'eula=true' > $@

$(TWEAKED_JAR_PATH): server
	mkdir -p server/mods
	cd server/mods && curl -O $(TWEAKED_URL)

.PHONY: mod
mod: $(TWEAKED_JAR_PATH)

$(README_CLIENT):
	echo "# Client Installation" > $@
	echo "" >> $@
	echo '1. Download' $(FORGE_INST_URL) >> $@
	echo '2. Run it and install to your client location' >> $@
	echo '3. Download' $(TWEAKED_URL) >> $@
	echo '4. Place it in your client `mods/` directory' >> $@

.PHONY: readme-client
readme-client: $(README_CLIENT)

.PHONY: install
.DEFAULT: install
install: server $(EULA) mod start

$(START_SH):
	echo '#!/bin/sh' > $@	
	echo 'java -Xmx2G -jar '$(FORGE_SERVER_JAR_NAME)' nogui' >> $@
	chmod +x $@

.PHONY: start
start: $(START_SH)

.PHONY: clobber
clobber:
	$(RM) -R server
	$(RM) -R client
	$(RM) $(README_CLIENT)

.PHONY: clean
clean:
	$(RM) -R $(SRC_DIR)