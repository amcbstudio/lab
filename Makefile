SHELL := /bin/sh
PATH := $(CURDIR)/bin:$(PATH)
.PHONY: demo test golden recipes check

demo:
	@echo "== kv headers -> jsonl keys"
	@cat fixtures/kv/headers.txt | kv parse --delim colon --trim | jsonl keys
	@echo
	@echo "== kv logfmt -> jsonl keys"
	@cat fixtures/kv/logfmt.txt | kv parse --delim equals | jsonl keys
	@echo
	@echo "== jsonl get field"
	@cat fixtures/jsonl/events.jsonl | jsonl get user | head -n 3

golden:
	@mkdir -p expected/kv expected/jsonl
	@cat fixtures/kv/headers.txt | kv parse --delim colon --trim > expected/kv/headers.jsonl
	@cat fixtures/kv/logfmt.txt | kv parse --delim equals > expected/kv/logfmt.jsonl
	@cat fixtures/jsonl/events.jsonl | jsonl keys > expected/jsonl/events.keys.txt
	@echo "Wrote expected/*"

test:
	@echo "== validate fixtures"
	@cat fixtures/jsonl/events.jsonl | jsonl validate
	@echo "== compare against golden outputs"
	@tmp1=$$(mktemp -t amcb.XXXXXX) && tmp2=$$(mktemp -t amcb.XXXXXX) && \
	trap 'rm -f "$$tmp1" "$$tmp2"' EXIT INT TERM && \
	cat fixtures/kv/headers.txt | kv parse --delim colon --trim > "$$tmp1" && \
	diff -u expected/kv/headers.jsonl "$$tmp1" && \
	cat fixtures/kv/logfmt.txt | kv parse --delim equals > "$$tmp2" && \
	diff -u expected/kv/logfmt.jsonl "$$tmp2" && \
	cat fixtures/jsonl/events.jsonl | jsonl keys > "$$tmp1" && \
	diff -u expected/jsonl/events.keys.txt "$$tmp1" && \
	echo "OK"

recipes:
	@echo "== headers_to_jsonl"
	@recipes/headers_to_jsonl.sh
	@echo
	@echo "== logfmt_to_jsonl"
	@recipes/logfmt_to_jsonl.sh
	@echo
	@echo "== events_users"
	@recipes/events_users.sh

check: demo test
