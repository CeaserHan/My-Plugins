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

function Assert-Contains {
    param(
        [string]$Text,
        [string]$Needle,
        [string]$Label
    )
    if (-not $Text.Contains($Needle)) {
        Add-Failure "missing ${Label}: $Needle"
    }
}

function Assert-NotContains {
    param(
        [string]$Text,
        [string]$Needle,
        [string]$Label
    )
    if ($Text.Contains($Needle)) {
        Add-Failure "legacy $Label remains: $Needle"
    }
}

function Read-RequiredFile {
    param(
        [string]$Path,
        [string]$Label
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Failure "missing file ${Label}: $Path"
        return ''
    }
    return Get-Content -LiteralPath $Path -Encoding UTF8 -Raw
}

$skillPath = Join-Path $PluginRoot 'skills\01-designing-storyboard-shots\SKILL.md'
$cameraRulePath = Join-Path $PluginRoot 'references\visual-language\rules\2-camera-setup-rules.md'
$cameraLibraryPath = Join-Path $PluginRoot 'references\visual-language\library\2.机位-camera-setup.md'
$strategyPath = Join-Path $PluginRoot 'references\visual-strategy-protocol.md'

$skill = Read-RequiredFile $skillPath 'detailed-shot skill'
$cameraRule = Read-RequiredFile $cameraRulePath 'camera rule'
$cameraLibrary = Read-RequiredFile $cameraLibraryPath 'camera library'
$strategy = Read-RequiredFile $strategyPath 'visual strategy'

$heightList = '眼高、腰高、膝高、贴地、高位'
Assert-Contains $skill $heightList 'approved camera-height list in Skill'
Assert-Contains $cameraRule $heightList 'approved camera-height list in camera rule'
Assert-Contains $cameraLibrary $heightList 'approved camera-height list in camera library'
Assert-Contains $strategy $heightList 'approved camera-height list in visual strategy'

Assert-NotContains $skill '贴低机位' 'camera-height vocabulary in Skill'
Assert-NotContains $cameraRule '贴低机位' 'camera-height vocabulary in camera rule'
Assert-NotContains $strategy '贴低机位' 'camera-height vocabulary in visual strategy'

foreach ($entry in @(
    @{ Text = $skill; Label = 'Skill' },
    @{ Text = $cameraRule; Label = 'camera rule' },
    @{ Text = $cameraLibrary; Label = 'camera library' },
    @{ Text = $strategy; Label = 'visual strategy' }
)) {
    Assert-Contains $entry.Text '纵轴向方位角' "vertical-axis azimuth in $($entry.Label)"
}

Assert-Contains $skill '纵轴向方位角变化路径' 'whole-scene azimuth path in Skill'
Assert-Contains $strategy '纵轴向方位角变化路径' 'whole-scene azimuth path in visual strategy'
Assert-Contains $skill '眼高机位平视，纵轴向左四分之三侧，固定镜头' 'three-axis per-shot example'

$directorHeading = '## 导演形式分析'
$shotsHeading = '## 详细镜头设计'
$auditHeading = '## 成品审查'
Assert-Contains $skill $directorHeading 'visible director-analysis heading'
Assert-Contains $skill $auditHeading 'visible final-audit heading'
Assert-NotContains $skill '<details>' 'folded details tag'
Assert-NotContains $skill '<summary>' 'folded summary tag'
Assert-NotContains $skill '点击展开' 'folded click-to-expand copy'

$directorIndex = $skill.LastIndexOf($directorHeading, [System.StringComparison]::Ordinal)
$shotsIndex = $skill.IndexOf($shotsHeading, $directorIndex + $directorHeading.Length, [System.StringComparison]::Ordinal)
$auditIndex = $skill.IndexOf($auditHeading, $shotsIndex + $shotsHeading.Length, [System.StringComparison]::Ordinal)
if ($directorIndex -lt 0 -or $shotsIndex -lt 0 -or $auditIndex -lt 0 -or -not ($directorIndex -lt $shotsIndex -and $shotsIndex -lt $auditIndex)) {
    Add-Failure 'output order must be visible director analysis, detailed shots, visible final audit'
}

$newAuditItems = @(
    '1. `### 形式与调度落实审查`',
    '2. `### 运镜与机位角度变化审查`',
    '3. `### 连续性与锁定指令审查`'
)
foreach ($item in $newAuditItems) {
    Assert-Contains $skill $item 'three-item audit contract'
}

$legacyAuditItems = @(
    '1. `### 导演形式分析落实度`',
    '2. `### 运镜丰富度与运动节奏`',
    '3. `### 摄像机机位角度丰富度与节奏`',
    '4. `### 人物与场景调度`',
    '5. `### 原始指令符合度`'
)
foreach ($item in $legacyAuditItems) {
    Assert-NotContains $skill $item 'five-item audit contract'
}

foreach ($entry in @(
    @{ Text = $skill; Label = 'Skill' },
    @{ Text = $cameraRule; Label = 'camera rule' },
    @{ Text = $strategy; Label = 'visual strategy' }
)) {
    Assert-NotContains $entry.Text '水平视角' "ambiguous horizontal-view term in $($entry.Label)"
}

if ($failures.Count -gt 0) {
    Write-Host "FAIL: detailed shot design contract ($($failures.Count) issue(s))" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'PASS: detailed shot design contract' -ForegroundColor Green
exit 0
