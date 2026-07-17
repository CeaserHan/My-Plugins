param(
    [string]$PluginRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param([string]$Message)
    $script:failures.Add($Message)
}

function Read-RequiredFile {
    param([string]$RelativePath)
    $path = Join-Path $PluginRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Failure "missing file: $RelativePath"
        return ''
    }
    return Get-Content -LiteralPath $path -Encoding UTF8 -Raw
}

function Assert-Contains {
    param([string]$Text, [string]$Needle, [string]$Label)
    if (-not $Text.Contains($Needle)) {
        Add-Failure "missing ${Label}: $Needle"
    }
}

function Assert-NotContains {
    param([string]$Text, [string]$Needle, [string]$Label)
    if ($Text.Contains($Needle)) {
        Add-Failure "legacy ${Label} remains: $Needle"
    }
}

$drafting = Read-RequiredFile 'skills\01-drafting-storyboards\SKILL.md'
$merging = Read-RequiredFile 'skills\01-merging-long-takes\SKILL.md'
$designing = Read-RequiredFile 'skills\01-designing-storyboard-shots\SKILL.md'
$workflow = Read-RequiredFile 'references\workflow-contract.md'
$playbook = Read-RequiredFile 'references\drafting-playbook.md'
$selection = Read-RequiredFile 'references\directing\selection-guide.md'
$longTake = Read-RequiredFile 'references\long-take-contract.md'
$strategy = Read-RequiredFile 'references\visual-strategy-protocol.md'

foreach ($entry in @(
    @{ Text = $drafting; Label = 'drafting Skill' },
    @{ Text = $playbook; Label = 'drafting playbook' },
    @{ Text = $selection; Label = 'creator selection guide' },
    @{ Text = $workflow; Label = 'workflow contract' }
)) {
    Assert-Contains $entry.Text '通用模式' "creator-optional path in $($entry.Label)"
}
Assert-NotContains $drafting '用户未指定创作者：从索引推荐三位' 'mandatory creator selection'
Assert-Contains $drafting '用户主动要求推荐创作者' 'creator recommendation trigger'
Assert-Contains $designing '通用模式无需创作者资料' 'creator-optional detailed design'

Assert-Contains $workflow '明确且无歧义地批准当前完整草稿' 'semantic approval rule'
Assert-Contains $drafting '“这版没问题，锁定吧”' 'semantic approval example'
Assert-Contains $merging '明确且无歧义地批准当前完整修订草稿' 'semantic reapproval rule'
Assert-Contains $workflow '孤立的 `继续`、`下一步`、`可以`、`往下`' 'ambiguous approval guard'

Assert-Contains $designing '按场景条件加载' 'progressive rule loading'
Assert-NotContains $designing '逐一读取八份规则，不得跳过任何维度' 'mandatory eight-rule loading'
Assert-Contains $strategy '按可观察条件加载规则' 'conditional visual-rule loading'

Assert-Contains $designing '无新增音效，延续场景环境声' 'non-inventive sound fallback'
Assert-NotContains $designing '并设计与画面同步的音效' 'mandatory invented per-shot sound'

foreach ($entry in @(
    @{ Text = $designing; Label = 'detailed-shot Skill' },
    @{ Text = $strategy; Label = 'visual strategy' }
)) {
    Assert-NotContains $entry.Text '固定镜头占比达到 75%' "75 percent movement threshold in $($entry.Label)"
    Assert-NotContains $entry.Text '同一种高度+俯仰达到 70%' "70 percent setup threshold in $($entry.Label)"
}
Assert-Contains $designing '不得把比例当作设计目标或通过增减运镜迎合指标' 'anti-metric-gaming rule'

Assert-Contains $designing '默认使用标准模式' 'standard output mode'
Assert-Contains $designing '制片审计模式' 'full audit output mode'

Assert-Contains $merging '候选推荐不会修改草稿' 'long-take recommendation guard'
Assert-Contains $longTake '推荐候选' 'long-take recommendation path'
Assert-Contains $longTake '只有用户明确选定镜头 ID' 'no automatic long-take execution'

Assert-Contains $designing '参考<>中人物外观；参考<>场景氛围；参考<>道具。' 'Seedance reference line'
Assert-Contains $designing '每镜恰好两个物理行' 'Seedance two-line shot contract'

if ($failures.Count -gt 0) {
    Write-Host "FAIL: workflow flexibility contract ($($failures.Count) issue(s))" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'PASS: workflow flexibility contract' -ForegroundColor Green
exit 0
