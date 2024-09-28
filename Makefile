FBQN=esp32-bluepad32:esp32:esp32
SKETCH=main

init: update-index install-dependencies

update-index:
	arduino-cli core update-index --config-file arduino-cli.yaml
	arduino-cli lib  update-index --config-file arduino-cli.yaml

install-dependencies:
	arduino-cli core install esp32-bluepad32:esp32@4.1.0 --config-file arduino-cli.yaml
	arduino-cli lib install 'RoboCore - Vespa@1.3.0' --config-file arduino-cli.yaml

run: compile upload monitor

hexdump:
	if [ -d "$(SKETCH)/data" ]; then \
		cd $(SKETCH); \
		find data -type f -not -name '*.h' \
		| awk '{print "xxd --include " $$0 " > " $$0 ".h"}' \
		| sh; \
	fi

compile: hexdump
	arduino-cli compile $(SKETCH) --build-path .build/$(SKETCH) --fqbn $(FBQN) --library library --config-file arduino-cli.yaml

filesystem.spiffs:
	sudo chmod a+rw $(PORT)
	cat .arduino/data/packages/esp32/hardware/esp32/2.0.14/tools/partitions/default.csv
	.arduino/data/packages/esp32/tools/mkspiffs/0.2.3/mkspiffs --create $(SKETCH)/data --page 256 --block 4096 --size 917504 .build/$(SKETCH)/filesystem.spiffs
	python .arduino/data/packages/esp32/tools/esptool_py/4.5.1/esptool.py --baud 460800 --port $(PORT) --before default_reset --after hard_reset write_flash 0x310000 .build/$(SKETCH)/filesystem.spiffs

upload:
	sudo chmod a+rw $(PORT)
	arduino-cli upload $(SKETCH) --input-dir .build/$(SKETCH) --fqbn $(FBQN) --port $(PORT) --config-file arduino-cli.yaml

monitor:
	sudo chmod a+rw $(PORT)
	arduino-cli monitor --config baudrate=9600 --fqbn $(FBQN) --port $(PORT) --config-file arduino-cli.yaml

monitor-describe:
	sudo chmod a+rw $(PORT)
	arduino-cli monitor --describe --fqbn $(FBQN) --port $(PORT) --config-file arduino-cli.yaml

clean:
	rm -rf .build
	rm -rf .arduino

config-dump:
	arduino-cli config dump
