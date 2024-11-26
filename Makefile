FQBN=esp32-bluepad32:esp32:esp32
SKETCH=main
PORT=/dev/ttyUSB0

init: update-index install-cores install-libs

update-index:
	arduino-cli core update-index --config-file arduino-cli.yaml
	arduino-cli lib  update-index --config-file arduino-cli.yaml

install-cores:
	arduino-cli core install --config-file arduino-cli.yaml esp32-bluepad32:esp32@4.1.0

install-libs:
	arduino-cli lib  install --config-file arduino-cli.yaml 'RoboCore - Vespa@1.3.0'

run: compile upload monitor

compile:
	arduino-cli compile $(SKETCH) --build-path .build/$(SKETCH) --fqbn $(FQBN) --library library --config-file arduino-cli.yaml

upload:
	sudo chmod a+rw $(PORT)
	arduino-cli upload $(SKETCH) --input-dir .build/$(SKETCH) --fqbn $(FQBN) --port $(PORT) --config-file arduino-cli.yaml

monitor:
	sudo chmod a+rw $(PORT)
	arduino-cli monitor --config baudrate=115200 --fqbn $(FQBN) --port $(PORT) --config-file arduino-cli.yaml

monitor-describe:
	sudo chmod a+rw $(PORT)
	arduino-cli monitor --describe --fqbn $(FQBN) --port $(PORT) --config-file arduino-cli.yaml

clean:
	rm -rf .build
	rm -rf .arduino

config-dump:
	arduino-cli config dump
