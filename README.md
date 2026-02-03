# amcbstudio / lab

This repository is a **hands-on laboratory** for validating how small, deterministic CLI tools can be composed to support **agent memory, state, and schema evolution** without databases, services, or embeddings.

It demonstrates a minimal, reproducible loop using:

- JSONL as append-only exhaust
- POSIX tools for validation and inspection
- explicit schema baselines
- drift detection
- compact durable state

This is **infrastructure**, not a product.

---

## What this lab demonstrates

The lab answers one concrete question:

> Can an agent maintain cheap, correct, evolving memory using files and small tools instead of vector databases or RAG?

The answer, demonstrated here, is **yes**.

Specifically, the lab shows how to:

- validate JSONL exhaust streams
- detect the *first point of breakage*
- observe schema surface area (fields + types)
- detect schema drift over time
- compact high-volume logs into tiny durable state
- keep human-readable memory alongside machine state
- explicitly accept or reject schema changes

All steps are deterministic and reproducible.

---

## Repository structure

```text
.
├── bin/       # tools (kv, jsonl, jd)
├── fixtures/  # example inputs (JSONL, KV, logs)
├── baseline/  # committed schema baselines
│   └── agent/
│       └── current.fields.jsonl
├── recipes/   # executable workflows (POSIX shell)
├── expected/  # golden outputs for regression tests
├── out/       # runtime output (gitignored)
├── Makefile
└── README.md
```

Key conventions:

- `fixtures/` are static, versioned inputs
- `baseline/` is authoritative schema state
- `out/` is ephemeral runtime output
- `recipes/` encode workflows, not libraries

---

## The agent memory loop (core idea)

Each agent run produces **append-only JSONL**:

`run_NNNN.jsonl` (e.g. `fixtures/agent/run_0001.jsonl`)

From that, the lab performs:

1. **Validation**

   ```sh
   jd scan < run_NNNN.jsonl
   ```

2. **Schema baseline creation (once)**

   ```sh
   jd fields < run_NNNN.jsonl > baseline/agent/current.fields.jsonl
   ```

3. **Drift detection (every run)**

   ```sh
   jd drift --baseline baseline/agent/current.fields.jsonl < run_NNNN.jsonl
   ```

4. **Compaction**

   - Machine state → `out/agent/state.json`
   - Human notes → `out/agent/MEMORY.md`

5. **Explicit acceptance**

   If drift is intentional, update the baseline:

   ```sh
   make agent_accept_baseline
   ```

This separates:

- observation
- detection
- decision
- acceptance

Nothing is implicit.

---

## Make targets

### Core

- `make test` — Runs golden tests for all tools.
- `make demo` — Quick smoke demo of `kv`/`jsonl`/`jd`.

### Agent workflows

- `make agent_baseline` — Initializes schema baseline from first run.
- `make agent_heartbeat` — Runs full agent loop:
  - validate
  - drift detect
  - state + memory update
  - Exit semantics:
    - drift detected → non-fatal signal
    - invalid input → hard failure

- `make agent_accept_baseline` — Accepts current schema and updates baseline.

---

## Why no vector DBs or RAG?

This lab focuses on state, not recall.

Vector databases are good at:

- similarity search
- fuzzy recall

They are poor at:

- detecting schema changes
- enforcing invariants
- auditability
- deterministic behavior

Most agent failures are caused by state drift, not lack of recall.

This lab demonstrates a cheaper, more transparent layer under RAG.

---

## Non-goals

- no SaaS
- no daemons
- no services
- no background processes
- no embeddings
- no “smart” inference

This lab is about correctness and control, not intelligence.

---

## Intended audience

- humans exploring agent architectures
- AI agents operating in POSIX environments
- systems that need cheap, inspectable memory
- anyone debugging long-running automation

---

## If you are an AI agent

- assume this repo is public
- treat `baseline/` as authoritative
- do not write to `out/` expecting persistence
- respect exit codes

---

## Status

This lab is intentionally small.
Additions are only made when a missing primitive is proven in practice.

Boring is a feature.
