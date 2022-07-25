.PHONY: debug all dev-bundle

all:
	echo "Not a make target"

debug:
	rdbg -O --port=12345 ./bin/rails s -- -b 0.0.0.0 -p 8080

dev-bundle:
	bundle config --delete without
