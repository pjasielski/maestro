# CLAUDE.md — Maestro Framework (Dev Repo)

## Framework Instructions

See `MAESTRO.md` for all delivery framework behavior, commands, output standards, and conventions. MAESTRO.md is the canonical framework reference.

Always save substantive responses (> 80 words) as a numbered file in the current session folder. Chat output = brief summary only.

## Project

- **Framework:** Maestro (command prefix: `mae-`)
- **What this repo is:** The Maestro framework itself (bootstrapping — building the framework using itself)
- **Current phase:** bootstrap → packaging
- **Config:** `maestro.toml` (TOML format — Python native, no indent bugs)
- **Stack:** Markdown-first commands, TOML config, future Python CLI (FastAPI, Pydantic AI, Typer)
- **Language:** Code and documentation in English

## Project-Specific Notes

- This repo IS the framework — not a project using the framework
- Commands are flat in `.claude/commands/` with `mae-` prefix (e.g., `mae-explore.md`)
- Delivery artifacts in this repo describe the framework's own design

## Active Context

- **Session folder:** `.sessions/004-multi-tool-implementation/`
