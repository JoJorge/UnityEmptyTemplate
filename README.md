# UnityEmptyTemplate
Unity empty project template, only containing settings of git, IDE config and coding style settings

## Git 設定

**1. 換行符號規範**

- 預設使用LF
- Unity/IDE相關檔案使用CRLF

**2. merge設定**

- ProjectSetting相關檔案停用自動合併
- 額外加入unityyamlmerge處理Unity文字檔合併，安裝方式詳見[GitTools/readme.md](GitTools/readmd.md)

**3. Git LFS（預設關閉）**

LFS 規則預設全部註解，需要時手動解開。可包含以下類別：
- 3D 模型與動畫：`.fbx`, `.obj`, `.max`, `.blend`, `.ma`, `.mb`
- 音訊：`.wav`, `.mp3`, `.ogg`, `.aif`, `.aiff`
- 影片：`.mp4`, `.mov`, `.asf`, `.avi`, `.flv`
- 壓縮與編譯檔：`.zip`, `.7z`, `.rar`, `.dll`, `.so`, `.bundle`, `.assetbundle`
- Unity 大型資產：`.cubemap`, `.unitypackage`, `.physicMaterial`, `.physicsMaterial2D`
- 字型：`.ttf`, `.otf`

尚未安裝LFS的話，也可透過GitTools/裡面的工具協助安裝，詳見[GitTools/readme.md](GitTools/readmd.md)

## IDE 設定

**通用設定（所有檔案）：**

| 設定 | 值 |
|------|----|
| 換行符號 | LF |
| 編碼 | UTF-8 |
| 縮排風格 | space |
| 縮排大小 | 4 |
| 檔案結尾換行 | 是 |
| 去除行尾空白 | 是 |

**例外：CRLF 檔案**

`*.sln`, `*.csproj`, `*.bat` → CRLF  
`*.unity`, `*.prefab`, `*.asset`, `*.meta` → CRLF（避免 Unity 資源 hash 變化）