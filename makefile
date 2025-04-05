.PHONY: test
test:
	npx mocha test/index.js


.PHONY: build
build: test
	echo "todo"


.PHONY: testPerformance
testPerformance:
	node ./test/performance.js
