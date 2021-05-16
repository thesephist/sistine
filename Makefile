all: run

# build site
run:
	ink src/main.ink

# run all tests under test/
check:
	ink ./test/main.ink
t: check

fmt:
	inkfmt fix src/*.ink test/*.ink
f: fmt

