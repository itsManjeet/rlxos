IGNITE					?= build/ignite
DOCS_DIR				?= build/docs

$(IGNITE):
	@mkdir -p $(shell dirname $(IGNITE))
	go build -o $(IGNITE) rlxos/cmd/ignite

.PHONY: $(IGNITE) clean all docs

all: $(IGNITE)

clean:
	rm $(IGNITE)
	rm -rf $(DOCS_DIR)

TODO.ELEMENTS:
	grep -R "# TODO:" elements | sed 's/# TODO://g' | sed 's#elements/##g' > $@

docs:
	mdbook build -d $(DOCS_DIR)