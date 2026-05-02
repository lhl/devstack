---
title: Reality Check
tags: [tools, framework, python, epistemology, knowledge-base, claims, evidence]
sources:
  - https://github.com/lhl/realitycheck
links:
  - https://github.com/lhl/realitycheck
  - https://pypi.org/project/realitycheck/
  - https://github.com/lhl/realitycheck-data (example knowledge base)
---

# Reality Check

A framework for rigorous, systematic analysis of claims, sources, predictions, and argument chains.

## Overview

| Attribute | Value |
|-----------|-------|
| **Version** | 0.3.3 |
| **Language** | Python 3.11+ |
| **License** | Apache-2.0 |
| **Author** | Leonard Lin |
| **Repository** | github.com/lhl/realitycheck |
| **Status** | 454 tests |

## Purpose

> With so many hot takes, plausible theories, misinformation, and AI-generated content, sometimes, you need a `realitycheck`.

Reality Check helps build and maintain a unified knowledge base with:
- **Claim Registry**: Track claims with evidence levels, credence scores, and relationships
- **Source Analysis**: Structured 3-stage methodology (descriptive → evaluative → dialectical)
- **Evidence Links**: Connect claims to sources with location, quotes, and strength ratings
- **Reasoning Trails**: Document credence assignments with full epistemic provenance
- **Prediction Tracking**: Monitor forecasts with falsification criteria and status updates
- **Argument Chains**: Map logical dependencies and identify weak links
- **Semantic Search**: Find related claims across your entire knowledge base

## Architecture

- **Storage**: LanceDB (embedded vector database)
- **Embeddings**: sentence-transformers (CPU or GPU with PyTorch)
- **CLI**: Multiple entry points (`rc-db`, `rc-validate`, `rc-export`, `rc-migrate`, `rc-embed`, `rc-html-extract`)

## Installation

```bash
# With pip
pip install realitycheck

# With uv
uv pip install realitycheck
```

### GPU Support (Optional)

```bash
# NVIDIA CUDA 12.8
uv sync --extra-index-url https://download.pytorch.org/whl/cu128

# AMD ROCm 6.4
uv sync --extra-index-url https://download.pytorch.org/whl/rocm6.4
```

## Quick Start

### 1. Create Your Knowledge Base

```bash
mkdir my-research && cd my-research
rc-db init-project

# Creates:
#   .realitycheck.yaml    - Project config
#   data/realitycheck.lance/  - Database
#   analysis/sources/     - For analysis documents
#   tracking/             - For prediction tracking
#   inbox/                - For sources to process
#   reference/primary/    - Filed primary documents
#   reference/captured/   - Supporting materials
```

### 2. Set Environment Variable

```bash
export REALITYCHECK_DATA="data/realitycheck.lance"
```

### 3. Add Claims and Sources

```bash
# Add a claim
rc-db claim add \
  --text "AI training costs double annually" \
  --type "[F]" \
  --domain "TECH" \
  --evidence-level "E2" \
  --credence 0.8
# Output: Created claim: TECH-2026-001

# Add a source
rc-db source add \
  --id "epoch-2024-training" \
  --title "Training Compute Trends" \
  --type "REPORT" \
  --author "Epoch AI" \
  --year 2024 \
  --url "https://epochai.org/blog/training-compute-trends"
```

### 4. Search and Explore

```bash
# Semantic search
rc-db search "AI costs"

# List all claims
rc-db claim list --format text

# Check database stats
rc-db stats
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `rc-db init-project` | Initialize project structure and database |
| `rc-db claim add` | Add a new claim |
| `rc-db claim list` | List claims |
| `rc-db claim link` | Link claim to source |
| `rc-db source add` | Add a source |
| `rc-db source list` | List sources |
| `rc-db search` | Semantic search |
| `rc-db stats` | Database statistics |
| `rc-db backup` | Backup database |
| `rc-validate` | Verify claims against sources |
| `rc-export` | Export knowledge base |
| `rc-migrate` | Migrate database schema |
| `rc-embed` | Generate embeddings |

## Agent Integrations

Reality Check includes integrations for multiple AI coding agents:

| Agent | Integration |
|-------|-------------|
| **Claude Code** | Plugin via `integrations/claude-code/` |
| **OpenAI Codex** | Skill via `integrations/codex/` |
| **Amp** | Skill via `integrations/amp/` |
| **OpenCode** | Skill via `integrations/opencode/` |

These integrations allow the agent to query the knowledge base directly.

## Claim Taxonomy

Claims are tagged with:
- **Type**: `[F]`act, `[P]`rediction, `[C]`laim, `[Q]`uestion
- **Domain**: TECH, SCIENCE, POLICY, etc.
- **Evidence Level**: E1 (direct measurement), E2 (primary research), E3 (secondary analysis), E4 (expert assessment), E5 (anecdotal)
- **Credence**: 0.0-1.0 probability assignment

## Related

- [realitycheck-data](https://github.com/lhl/realitycheck-data) — Public example knowledge base
- [Reality Check on PyPI](https://pypi.org/project/realitycheck/)