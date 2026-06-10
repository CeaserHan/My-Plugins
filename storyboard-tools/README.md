# storyboard-tools

影视分镜工具包。将分镜脚本草稿扩写为完整人类可读分镜文档，再生成即梦 Seedance 2.0 提示词生产列表。

## Skills

| Skill | 描述 | 触发条件 |
|-------|------|---------|
| script-to-storyboard | 将脚本草稿扩写为完整分镜文档 | 帮我完善分镜、分镜草稿转完整分镜 |
| seedance-prompts | 生成即梦 Seedance 2.0 提示词列表 | 给我提示词列表、生成即梦提示词 |

> seedance-prompts 必须在 script-to-storyboard 输出之后使用。

## Structure

```
storyboard-tools/
├── skills/
│   ├── script-to-storyboard/
│   │   ├── SKILL.md
│   │   ├── evals/evals.json
│   │   └── references/novel-parse.md
│   └── seedance-prompts/
│       ├── SKILL.md
│       └── references/seedance-fmt.md
├── templates/       # 分镜模板（待补充）
├── examples/        # 示例输出（待补充）
└── tests/           # 测试用例（待补充）
```

## Entry Points

- Claude / Cowork: `/.claude-plugin/plugin.json`
- Codex / OpenAI agents: `/AGENTS.md`

## Author

Taylorel Mcleandi
