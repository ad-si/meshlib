#! /usr/bin/env node

require('coffee-script/register')

const cli = require('../source/cli')

cli(process.argv)
