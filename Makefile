SHELL = /bin/bash
# variables to use sandboxed binaries
PIP := env/bin/pip
PY := env/bin/python
TEST-BIN := test-env/bin/
NOSE := $(TEST-BIN)/nosetests
COV := $(TEST-BIN)/coverage
TEST-PIP := $(TEST-BIN)/pip
TEST-PY := $(TEST-BIN)/python

# -------- Environment --------
# env is a folder so no phony is necessary
env:
	virtualenv env

.PHONY: deps
deps: env packages/.done
	# see http://tartley.com/?p=1423&cpage=1
	# --upgrade needed to force local (if there's a system install)
	$(PIP) install --no-index --find-links=file://$${PWD}/packages

packages/.done:
	mkdir packages; \
	$(PIP) install --download packages  && \
	touch packages/.done

testdeps: deps packages/.test.done
	$(TEST-PIP) install --no-index --find-links=file://$${PWD}/packages  ;\
	$(TEST-PIP) install --no-index --find-links=file://$${PWD}/packages

packages/.test.done:
	mkdir packages; \
	$(PIP) install --download packages && \
	touch packages/.test.done



# rm_env isn't a file so it needs to be marked as "phony"
.PHONY: rm_env
rm_env:
	rm -rf env


# --------- Dev --------------------
.PHONY: dev
dev: deps
	$(PY) setup.py develop


# --------- Testing ----------
test-env:
	virtualenv test-env

.PHONY: test
test: test-env deps testdeps build
	#$(TEST-PIP) uninstall --force rst2epub2; $(TEST-PIP) install dist/rst2epub*;\
	$(TEST-PY) setup.py develop;\
	$(NOSE); $(COV) run $(TEST-BIN)/rst2epub.py --traceback -r 3 sample/sample.rst /tmp/sample.epub; $(COV) html -d html-cov
# --------- PyPi ----------
.PHONY: build
build: env
	$(PY) setup.py sdist

.PHONY: upload
upload: env
	$(PY) setup.py sdist register upload

.PHONY: clean
clean:
	rm -rf dist *.egg-info
