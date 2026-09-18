此資料夾為輔助Unity專案進行Mutation Test的資料夾，內含測試用的中繼csproj
前置需求：
- 安裝dotnet，如使用dotnet framework，需安裝nuget，可參考[官方安裝教學](https://stryker-mutator.io/docs/stryker-net/getting-started/#dotnet-framework-specific)
- 安裝stryker
    - 如專案完全沒裝過stryker，可參考[官方安裝教學](https://stryker-mutator.io/docs/stryker-net/getting-started/#install-in-project)。
    - 如已有人安裝過，執行`dotnet tool restore`即可。
- 待測試的程式功能有使用asmdef包起來
- 待測試功能不相依UnityEngine

測試步驟：
1. 複製TemplateTestProj.csproj和template-stryker-config.json到功能測試資料夾
2. 重命名csproj為TestProj.csproj，調整其中的ProjectReference和Compile以對應功能專案與測試程式資料夾
3. 重命名json為stryker-config.json，調整其中的mutate以對應要變異功能，並排除測試程式
4. 使用dotnet styker進行變異測試
    - 如果template使用的套件版本有問題，可以嘗試使用`dotnet new nunit -n TestProj`重新生成template。
5. 分析styker產出的結果報告   