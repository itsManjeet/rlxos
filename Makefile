IGNITE					?= ignite

$(IGNITE):
	@mkdir -p $(shell dirname $(IGNITE))
	go build -o $(IGNITE) rlxos/cmd/ignite

all: $(IGNITE)

clean:
	rm $(IGNITE)

.PHONY: $(IGNITE) clean all

TODO.ELEMENTS:
	grep -R "# TODO:" elements | sed 's/# TODO://g' | sed 's#elements/##g' > $@