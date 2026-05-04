#!/usr/bin/env bash
# Unity 專案 Git 設定腳本
# 支援 Linux 與 macOS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITCONFIG_LOCAL="$SCRIPT_DIR/.gitconfig.local"

# ── 步驟一：確認 UnityYAMLMerge ──────────────────────────────────────────────

if command -v unityyamlmerge &>/dev/null; then
    echo "✔ 已在 PATH 中找到 unityyamlmerge：$(command -v unityyamlmerge)"
else
    echo "✘ PATH 中找不到 unityyamlmerge。"
    read -rp "是否自動嘗試尋找並加入 PATH？[y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        # 常見安裝路徑
        SEARCH_PATHS=(
            "/Applications/Unity/Hub/Editor"
            "$HOME/Applications/Unity/Hub/Editor"
            "/opt/unity"
            "/usr/local/bin"
        )
        FOUND=""
        for base in "${SEARCH_PATHS[@]}"; do
            hit=$(find "$base" -name "unityyamlmerge" -type f 2>/dev/null | head -1)
            if [[ -n "$hit" ]]; then
                FOUND="$hit"
                break
            fi
        done

        if [[ -n "$FOUND" ]]; then
            FOUND_DIR="$(dirname "$FOUND")"
            echo "✔ 找到：$FOUND"

            # 判斷使用的 shell 設定檔
            if [[ "$SHELL" == */zsh ]]; then
                RC_FILE="$HOME/.zshrc"
            else
                RC_FILE="$HOME/.bashrc"
            fi

            EXPORT_LINE="export PATH=\"$FOUND_DIR:\$PATH\""
            if grep -qF "$FOUND_DIR" "$RC_FILE" 2>/dev/null; then
                echo "  PATH 已存在於 $RC_FILE，略過寫入。"
            else
                printf "\n# UnityYAMLMerge\n%s\n" "$EXPORT_LINE" >> "$RC_FILE"
                echo "✔ 已永久寫入 $RC_FILE（重新開啟終端機後生效）"
            fi
            export PATH="$FOUND_DIR:$PATH"
        else
            echo "  自動搜尋失敗，請手動安裝或設定 unityyamlmerge 的路徑。"
        fi
    else
        echo "  略過 unityyamlmerge 設定。"
    fi
fi

# ── 步驟二：將 .gitconfig.local 套用至當前專案 config ────────────────────────

if [[ ! -f "$GITCONFIG_LOCAL" ]]; then
    echo "錯誤：找不到 $GITCONFIG_LOCAL" >&2
    exit 1
fi

# 確認目前在 git 專案內
if ! git rev-parse --git-dir &>/dev/null; then
    echo "錯誤：目前目錄不在 git 專案中，請先執行 git init。" >&2
    exit 1
fi

echo "套用 $GITCONFIG_LOCAL 至專案 git config..."
GIT_DIR=$(git rev-parse --git-dir)
REL_PATH=$(realpath --relative-to="$(realpath "$GIT_DIR")" "$(realpath "$GITCONFIG_LOCAL")")
git config --local include.path "$REL_PATH"
echo "✔ 已設定 include.path = $REL_PATH（僅限本專案）"

# ── 步驟三：確認設定是否正確 ─────────────────────────────────────────────────

echo ""
echo "── 驗證結果 ──"

# 3-1：check-attr 確認 .gitattributes
MERGE_ATTR=$(git check-attr merge -- SceneName.unity | awk '{print $NF}')
if [[ "$MERGE_ATTR" == "unityyamlmerge" ]]; then
    echo "✔ [gitattributes] SceneName.unity merge driver = $MERGE_ATTR"
else
    echo "✘ [gitattributes] merge = ${MERGE_ATTR:-未設定}，請確認 .gitattributes 包含 '*.unity merge=unityyamlmerge'。"
fi

# 3-2：git config 確認 merge driver 已設定
DRIVER=$(git config merge.unityyamlmerge.driver 2>/dev/null)
if [[ -n "$DRIVER" ]]; then
    echo "✔ [git config] merge.unityyamlmerge.driver = $DRIVER"
else
    echo "✘ [git config] merge.unityyamlmerge.driver 未設定，請確認 .gitconfig.local 已正確載入。"
fi

# 3-3：確認 unityyamlmerge 可執行
if command -v unityyamlmerge &>/dev/null; then
    echo "✔ [PATH] unityyamlmerge 可執行：$(command -v unityyamlmerge)"
else
    echo "✘ [PATH] unityyamlmerge 不在 PATH 中，merge 時將無法驅動。"
fi
