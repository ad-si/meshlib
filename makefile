.PHONY: typecheck
typecheck:
	npx tsc --noEmit


.PHONY: test
test:
	-npx tsc --noEmit
	npx tsx ./node_modules/.bin/mocha test/index.ts

.PHONY: test-only
test-only:
	npx tsx ./node_modules/.bin/mocha test/index.ts


.PHONY: build
build: test
