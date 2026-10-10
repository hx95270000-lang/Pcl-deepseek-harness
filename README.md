# PCL + DeepSeek Harness 启动器

以 **Plain Craft Launcher 2（PCL）** 的 UI 为基础改造的启动器：保留 PCL 原有的全部功能（启动 Minecraft、下载、版本管理、整合包导出等），并在顶部导航栏新增 **DeepSeek** 页面，用于启动和管理 **DeepSeek Harness**。

---

## 一、成果概览

| 项目 | 说明 |
| --- | --- |
| 可执行文件 | \_src\PCL-main\Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe |
| 源码位置 | \_src\PCL-main\（PCL 源码 + 本次新增模块） |
| 新增命名空间 | PCL.DeepSeek（ModDsh / ModDshOllama） |
| 新增页面 | Pages\PageDeepSeek\（启动器左侧导航 + 3 个功能页） |
| 构建方式 | MSBuild（.NET Framework 4.8 / VB.NET / WPF） |

### 新增 / 修改的文件

**新增**

- Modules\DeepSeek\ModDsh.vb —— 实例模型、配置读写、补丁生成、启动、7z 整合包导出导入
- Modules\DeepSeek\ModDshOllama.vb —— Ollama 检测、模型拉取、WSL/Ubuntu 自动部署
- Pages\PageDeepSeek\PageDeepSeekLeft.xaml(.vb) —— DeepSeek 页面的左侧导航
- Pages\PageDeepSeek\PageDshLaunch.xaml(.vb) —— 启动与实例管理
- Pages\PageDeepSeek\PageDshConfig.xaml(.vb) —— 自定义插件、内存与模型、Ollama
- Pages\PageDeepSeek\PageDshPack.xaml(.vb) —— 整合包导出 / 导入

**修改**

- FormMain.xaml —— 顶部导航新增 "DeepSeek" 按钮（Tag=10）
- FormMain.xaml.vb —— PageType.Dsh、PageSubType、按 Tag 查找导航按钮、页面切换分支
- Modules\ModMain.vb —— DeepSeek 页面字段声明
- Plain Craft Launcher 2.vbproj —— 注册新增的 .vb / .xaml
- Plain Craft Launcher 2\My Project\Resources.resx 改为由 ResGen 预编译（见"构建说明"）

---

## 二、构建说明

### 1. 为什么需要特殊处理

- **NuGet 无法联网**：本机 TLS 被拦截，已把依赖包预先下载到 \_src\localnuget\，并在 \_src\PCL-main\nuget.config 中把源指向该目录。
- **MSB3821**：VS 18 的 GenerateResource 任务会拒绝处理含 ResXFileRef 的 .resx。已改为用 ResGen.exe 预编译出 Resources.resources 后直接嵌入，绕开该任务。
- **文件"来自 Internet"标记**：首次解压后需解封（Unblock-File）。
- **dotnet 首次运行哨兵文件**：需把 DOTNET_CLI_HOME 指到可写目录。

### 2. 一键构建

直接运行仓库根目录的 build.cmd（会自行设置环境变量并调用 MSBuild）。

### 3. 手动构建

    set DOTNET_CLI_HOME=<可写目录>\.dotnet
    set NUGET_PACKAGES=<可写目录>\.nuget
    dotnet restore _src\PCL-main\PCLCS\PCLCS.csproj
    "<VS>\MSBuild\Current\Bin\MSBuild.exe" "_src\PCL-main\Plain Craft Launcher 2\Plain Craft Launcher 2.vbproj" -p:Configuration=Release -m:1 -nodeReuse:false

修改过 Resources.resx 后需要在本目录重新生成资源：

    cd "_src\PCL-main\Plain Craft Launcher 2\My Project"
    "<Windows SDK>\bin\NETFX 4.8 Tools\ResGen.exe" Resources.resx Resources.resources

---

## 三、使用说明

打开程序后点击顶部 **DeepSeek** 标签，左侧有三个页面。

### 1. 启动（实例管理）

- **选择实例 / 新建 / 复制 / 删除**：每个实例保存自己的运行位置、DSH_HOME、profile、插件、内存与模型设置。
- **运行位置**：本机 Windows 或 WSL 子系统。选 WSL 时填写发行版名称，命令会通过 wsl.exe 执行。
- **DSH_HOME**：DeepSeek Harness 的数据目录（含 profiles）。留空使用默认 ~/.dsh。
- **dsh 命令**：留空自动探测；"自动探测"按钮会在 Program Files 与 PATH 中查找 dsh.cmd。
- **Profile**：下拉列出可用的 profile。"初始化"按钮会用 dsh 内置模板新建一个可被 CLI 启动的 profile（desktop 只能由桌面端使用，会自动跳过）。
- **校验配置**：执行 dsh --dump-config，用退出码判断配置能否被正常解析。
- **启动 DeepSeek Harness**：按当前配置启动，输出实时显示在下方。
- **停止**：结束由本启动器拉起的进程。

### 2. 插件与内存

- **自定义插件**：填写 npm 包名（如 @deepseek-ai/dsh-plugin-manager），可附加 YAML 配置片段，并可单独启用/禁用。插件通过 dsh 的 --patch 覆盖层注入，**不会修改 DeepSeek Harness 的安装文件**。
- **内存与上下文**：上下文窗口、最大输出 tokens、自动压缩开关与阈值。
- **模型**：provider、模型名、推理强度；勾选"使用本地 Ollama"后会自动把 provider 改写为 ollama 并写入 OpenAI 兼容端点。
- **Ollama 运行环境**：检测环境 / 自动部署（WSL + Ubuntu + Ollama）/ 启动服务。

### 3. 整合包

- **导出**：把实例配置与该实例的 DSH_HOME（profile 配置 + 自定义插件）打包为 .7z；自动排除 sessions、storages、node_modules。
- **导入**：解包并新增一个实例，重名自动加序号。
- 需要本机安装 7-Zip（会自动在 Program Files 与 PCL 目录中查找 7z.exe）。

---

## 四、实现要点

### 配置注入方式

DeepSeek Harness 的 profile 由多层 YAML 补丁叠加而成。启动器**不修改** Harness 安装目录，而是在每次启动前生成一个补丁文件，通过 --patch 参数注入：

    PCL\DeepSeek\Patches\<实例名>.yml

生成的补丁形如：

    - id: agent-default-model
      config:
        provider: ollama
        model: "qwen2.5:7b"
        reasoningEffort: high
    - id: llm
      config:
        providers:
          ollama:
            displayName: Ollama (本地)
            api: openai-completions
            baseURL: "http://127.0.0.1:11434/v1"
            apiKeyEnv: OLLAMA_API_KEY
    - id: compaction-basic
      config:
        enabled: true
        thresholdPercent: 70
    - id: token-meter
      config:
        contextWindow: 32768
        maxOutputTokens: 4096

### 本地模型（Ollama）

Ollama 暴露的 OpenAI 兼容接口（/v1）可以直接被 Harness 当作 provider 使用，因此"接入本地模型"不需要修改 Harness，只需要上面的补丁。当本机没有 Ollama 时，可以在"插件与内存 → Ollama 运行环境"中一键部署：检测 WSL → 必要时 wsl --install -d Ubuntu → 官方脚本安装 Ollama → 后台启动服务 → 拉取模型。

### 数据目录

实例列表与补丁文件存放在程序目录下（与 PCL 其他数据一致，便于随程序携带）：

    <PCL 目录>\PCL\DeepSeek\Instances.json
    <PCL 目录>\PCL\DeepSeek\Patches\*.yml

---

## 五、已知注意事项

1. **注册表写入**：当前环境下 PCL 无法写入 HKCU\Software\PCLDebug，因此设置项不会持久化，每次启动都会重新显示"协议授权""开源版本说明"对话框。这是运行环境权限问题，不是本改造引入的缺陷。
2. **从源码构建的版本缺少内置密钥**：CurseForge API、微软正版登录等需要自行在 ModSecret.vb 中填写，PCL 会为此弹出"开源版本说明"。
3. **WSL 相关功能**需要本机已启用 WSL；自动安装 Ubuntu 通常需要管理员权限并可能要求重启。
4. **调试期临时措施**：验证时使用 launch_pcl.cmd 把 TEMP/TMP 指向工作区，因为在本机沙箱下新建系统临时目录会被拒绝。正常双击运行不需要这个脚本。
