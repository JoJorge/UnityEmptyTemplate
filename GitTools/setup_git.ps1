# Unity 專案 Git 設定腳本（Windows）
# 需以 PowerShell 執行

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$GitconfigLocal = Join-Path $ScriptDir ".gitconfig.local"

# ── 步驟一：確認 UnityYAMLMerge ──────────────────────────────────────────────

if (Get-Command unityyamlmerge -ErrorAction SilentlyContinue) {
    Write-Host "✔ 已在 PATH 中找到 unityyamlmerge：$((Get-Command unityyamlmerge).Source)"
} else {
    Write-Host "✘ PATH 中找不到 unityyamlmerge。"
    $ans = Read-Host "是否自動嘗試尋找並加入 PATH？[y/N]"
    if ($ans -match "^[Yy]$") {
        # 常見 Unity Hub 安裝路徑
        $SearchRoots = @(
            "$env:PROGRAMFILES\Unity\Hub\Editor",
            "$env:PROGRAMFILES(X86)\Unity\Hub\Editor",
            "$env:LOCALAPPDATA\Programs\Unity\Hub\Editor"
        )

        $Found = $null
        foreach ($root in $SearchRoots) {
            if (Test-Path $root) {
                $Found = Get-ChildItem -Path $root -Recurse -Filter "UnityYAMLMerge.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($Found) { break }
            }
        }

        if ($Found) {
            $FoundDir = $Found.DirectoryName
            Write-Host "✔ 找到：$($Found.FullName)"

            # 讀取目前使用者的 PATH
            $CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            if ($CurrentPath -like "*$FoundDir*") {
                Write-Host "  PATH 已包含該目錄，略過寫入。"
            } else {
                [Environment]::SetEnvironmentVariable("PATH", "$CurrentPath;$FoundDir", "User")
                Write-Host "✔ 已永久寫入使用者 PATH（重新開啟終端機後生效）"
            }
            # 本次立即生效
            $env:PATH = "$env:PATH;$FoundDir"
        } else {
            Write-Host "  自動搜尋失敗，請手動安裝或設定 UnityYAMLMerge 的路徑。"
        }
    } else {
        Write-Host "  略過 UnityYAMLMerge 設定。"
    }
}

# ── 步驟二：將 .gitconfig.local 套用至當前專案 config ────────────────────────

if (-not (Test-Path $GitconfigLocal)) {
    Write-Error "錯誤：找不到 $GitconfigLocal"
    exit 1
}

git rev-parse --git-dir | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "錯誤：目前目錄不在 git 專案中，請先執行 git init。"
    exit 1
}

Write-Host "套用 $GitconfigLocal 至專案 git config..."
$RepoRoot = (Resolve-Path (git rev-parse --show-toplevel)).Path.TrimEnd("\")
$RelPath = "../" + $GitconfigLocal.Substring($RepoRoot.Length).TrimStart("\").Replace("\", "/")
git config --local include.path $RelPath
Write-Host "✔ 已設定 include.path = $RelPath（僅限本專案）"

# ── 步驟三：Git LFS ──────────────────────────────────────────────────────────

$useLfs = Read-Host "是否使用 Git LFS？[y/N]"
if ($useLfs -match "^[Yy]$") {
    if (-not (Get-Command git-lfs -ErrorAction SilentlyContinue)) {
        Write-Host "安裝 Git LFS..."
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install -e --id GitHub.GitLFS
        } else {
            Write-Host "✘ 無法自動安裝，請手動安裝 git-lfs：https://git-lfs.com"
        }
    }
    if (Get-Command git-lfs -ErrorAction SilentlyContinue) {
        git lfs install
        Write-Host "✔ Git LFS 已啟用"
        Write-Host "⚠ 提醒：請解除 .gitattributes 中 LFS 相關規則的註解。"
    }
} else {
    Write-Host "  略過 Git LFS 設定。"
}

# ── 步驟四：確認設定是否正確 ─────────────────────────────────────────────────

Write-Host ""
Write-Host "── 驗證結果 ──"

# 4-0：LFS（僅在步驟三選擇使用時檢查）
if ($useLfs -match "^[Yy]$") {
    git lfs env 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✔ [LFS] Git LFS 已正確安裝並啟用"
    } else {
        Write-Host "✘ [LFS] Git LFS 未正確安裝，請重新執行安裝步驟。"
    }
}

# 3-1：check-attr 確認 .gitattributes
$attrOutput = git check-attr merge -- SceneName.unity
$mergeAttr = ($attrOutput -split ':')[-1].Trim()
if ($mergeAttr -eq "unityyamlmerge") {
    Write-Host "✔ [gitattributes] SceneName.unity merge driver = $mergeAttr"
} else {
    Write-Host "✘ [gitattributes] merge = $mergeAttr，請確認 .gitattributes 包含 '*.unity merge=unityyamlmerge'。"
}

# 3-2：git config 確認 merge driver 已設定
$driver = git config merge.unityyamlmerge.driver 2>$null
if ($driver) {
    Write-Host "✔ [git config] merge.unityyamlmerge.driver = $driver"
} else {
    Write-Host "✘ [git config] merge.unityyamlmerge.driver 未設定，請確認 .gitconfig.local 已正確載入。"
}

# 3-3：確認 unityyamlmerge 可執行
if (Get-Command unityyamlmerge -ErrorAction SilentlyContinue) {
    Write-Host "✔ [PATH] unityyamlmerge 可執行：$((Get-Command unityyamlmerge).Source)"
} else {
    Write-Host "✘ [PATH] unityyamlmerge 不在 PATH 中，merge 時將無法驅動。"
}
