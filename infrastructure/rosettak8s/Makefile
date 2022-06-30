.PHONY: all clean

all: rosetta-latest.yaml

rosetta-latest.yaml:
	curl -s https://raw.githubusercontent.com/robyrobot/rosettak8s/main/install.sh \
		| ARCH_LIST=amd64 sh > rosetta-latest.yaml

clean:
	rm -f rosetta-latest.yaml
