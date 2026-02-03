SHELL := /bin/sh
PATH := $(CURDIR)/bin:$(PATH)
.PHONY: demo test golden recipes check jd_demo

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
	@mkdir -p expected/kv expected/jsonl expected/jd
	@cat fixtures/kv/headers.txt | kv parse --delim colon --trim > expected/kv/headers.jsonl
	@cat fixtures/kv/logfmt.txt  | kv parse --delim equals > expected/kv/logfmt.jsonl
	@cat fixtures/jsonl/events.jsonl | jsonl keys > expected/jsonl/events.keys.txt

	@cat fixtures/jsonl/events.jsonl | jd scan   > expected/jd/events.scan.json
	@cat fixtures/jsonl/events.jsonl | jd fields > expected/jd/events.fields.jsonl

	@cat fixtures/jsonl/events_drift.type_change.jsonl \
		| jd drift --baseline expected/jd/events.fields.jsonl \
		> expected/jd/drift_type_change.jsonl || true

	@cat fixtures/jsonl/events_drift.event_colon.jsonl \
		| jd drift --baseline expected/jd/events.fields.jsonl \
		> expected/jd/drift_event_colon.jsonl || true

	@echo "Wrote expected/*"


test: golden
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
	cat fixtures/jsonl/events.jsonl | jd scan > "$$tmp1" && \
	diff -u expected/jd/events.scan.json "$$tmp1" && \
	cat fixtures/jsonl/events.jsonl | jd fields > "$$tmp1" && \
	diff -u expected/jd/events.fields.jsonl "$$tmp1" && \
	set +e; cat fixtures/jsonl/events_drift.type_change.jsonl | jd drift --baseline expected/jd/events.fields.jsonl > "$$tmp1"; rc=$$?; set -e; \
	test "$$rc" -eq 1 && diff -u expected/jd/drift_type_change.jsonl "$$tmp1" && \
	set +e; cat fixtures/jsonl/events_drift.event_colon.jsonl | jd drift --baseline expected/jd/events.fields.jsonl > "$$tmp1"; rc=$$?; set -e; \
	test "$$rc" -eq 1 && diff -u expected/jd/drift_event_colon.jsonl "$$tmp1" && \
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
	@echo
	@echo "== jd_scan_broken_syntax"
	@recipes/jd_scan_broken_syntax.sh
	@echo
	@echo "== jd_fields_events"
	@recipes/jd_fields_events.sh
	@echo
	@echo "== jd_drift_type_change"
	@recipes/jd_drift_type_change.sh
	@echo
	@echo "== jd_drift_event_colon"
	@recipes/jd_drift_event_colon.sh || true

jd_demo:
	@echo "== scan valid"
	@cat fixtures/jsonl/events.jsonl | jd scan
	@echo "== scan broken (expect error)"
	@cat fixtures/jsonl/events_broken.syntax.jsonl | jd scan || true
	@echo "== fields"
	@cat fixtures/jsonl/events.jsonl | jd fields | sed -n '1,12p'

check: demo test recipes
