.PHONY: typecheck
typecheck:
	npx tsc --noEmit


.PHONY: test
test:
	-npx tsc --noEmit
	npx tsx ./node_modules/.bin/mocha test/index.ts test/faceVertexMesh.ts

.PHONY: test-only
test-only:
	npx tsx ./node_modules/.bin/mocha test/index.ts test/faceVertexMesh.ts


.PHONY: build
build: test
	rm -rf build
	npx tsc --project tsconfig.build.json
	chmod +x build/cli/index.js
