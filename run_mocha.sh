#!/bin/bash
NODE_PATH=suite/ mocha --compilers coffee:coffee-script/register example/tests/example_test.coffee
