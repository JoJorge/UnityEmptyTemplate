# GitTools使用說明

提供 Git 初始化腳本，適用 Windows（PowerShell, ps1）與 macOS/Linux（Shell, sh）。

將對應平台腳本放到git專案資料夾中，直接執行，即可自動設定unityyamlmerge與LFS。

**詳細步驟說明：**

1. **確認 UnityYAMLMerge**  
   檢查 `unityyamlmerge` 是否在 PATH 中。若無，可選擇自動搜尋 Unity Hub 安裝路徑並寫入使用者 PATH（Windows：搜尋 `%PROGRAMFILES%\Unity\Hub\Editor` 等路徑）。

2. **套用 `.gitconfig.local`**  
   將 `GitTools/.gitconfig.local` 以 `include.path` 方式注入至專案本地 git config（僅限本專案，不影響全域設定）。

3. **Git LFS（可選）**  
   詢問是否啟用 LFS。若選擇是且未安裝，Windows 使用 `winget` 自動安裝 `GitHub.GitLFS`；macOS/Linux 提示手動安裝。啟用後執行 `git lfs install`，並提醒解除 `.gitattributes` 中的 LFS 註解。

4. **驗證設定**  
   腳本結束前自動驗證：
   - LFS 是否正確安裝（若啟用）
   - `.gitattributes` 中 `.unity` 的 merge driver 是否為 `unityyamlmerge`
   - `git config merge.unityyamlmerge.driver` 是否已設定
   - `unityyamlmerge` 是否可在 PATH 執行
