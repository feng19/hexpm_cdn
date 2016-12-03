.PHONY: run compile clean

all: compile

run:
	rebar3 shell

compile:
	rebar3 compile

clean:
	rebar3 clean
