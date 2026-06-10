# Agent Skills — CeaserHan/my-claude-plugins

This repository contains shared AI skills for use with Claude, Codex, and other agents.

## Available Skills

When the user asks for storyboard, script breakdown, or Seedance prompt work, read the following skill files:

- `storyboard-tools/skills/script-to-storyboard/SKILL.md`
- `storyboard-tools/skills/seedance-prompts/SKILL.md`

## Skill Descriptions

### script-to-storyboard
将分镜脚本草稿扩写为完整人类可读分镜文档（画面内容、台词、音效、导演意图）。
Trigger: user asks to expand a storyboard draft, break down a script into shots, or complete a storyboard.

Reference files:
- `storyboard-tools/skills/script-to-storyboard/SKILL.md` — main skill instructions
- `storyboard-tools/skills/script-to-storyboard/references/novel-parse.md` — novel/prose parsing guide
- `storyboard-tools/skills/script-to-storyboard/evals/evals.json` — evaluation cases

### seedance-prompts
读取 script-to-storyboard 生成的完整分镜，构建即梦 Seedance 2.0 提示词生产列表。
Trigger: user asks for Seedance prompts, prompt list, or wants to paste prompts into Seedance.
Prerequisite: must have script-to-storyboard output first.

Reference files:
- `storyboard-tools/skills/seedance-prompts/SKILL.md` — main skill instructions
- `storyboard-tools/skills/seedance-prompts/references/seedance-fmt.md` — Seedance 2.0 formatting guide

## Entry Points

| Agent | Entry File |
|-------|-----------|
| Claude / Cowork | `.claude-plugin/plugin.json` |
| Codex / OpenAI agents | This file (AGENTS.md) |

## Shared Skill Content

All skills live in `storyboard-tools/skills/`. Both Claude and Codex read the same SKILL.md files.
