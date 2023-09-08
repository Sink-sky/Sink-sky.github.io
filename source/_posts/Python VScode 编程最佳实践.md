---
title: Python VScode 编程最佳实践
date: 2023-09-08 15:32:36
tags:
	- Tool
categories:
	- Coding
---

## 引言
最近看到 [Hypermodern Python](https://cjolowicz.github.io/posts/hypermodern-python-01-setup/) 一文，又联想到以前看过 Effective Modern C++ 一书。尽管以现在的角度看来，Effective Modern C++ 中讲述的 C++11 已经不够 Modern 了，但是总的这些经验与总结，也有值得学习的地方。之所以要 Modern，是为了要避免有隐患的操作，或者是形成一套标准，在标准的基础上做更多建设，达到 Best Practice。因此写一篇文章，记载下现在的 Modern Python。

## 项目结构
在学习一门编程语言的时候，往往大家注意点都在其本身的语法与语义上，但要将编程工作组织模块化工程化，还需要注意其本身的构建环境、依赖管理、工具链生态等。想想在使用静态代码检查工具的时候，往往需要配置包路径在哪；C 语言规定 main 函数是一个应用程序的入口；在进行分布式代码协作的时候，我依赖其他人的包，要如何进行依赖管理。项目本身是一系列模块化的代码组织，而构建相关描述决定如何组合在一起。

首先先来看下标准的 Python 项目结构是什么样的，其大致有两种：

        # 扁平化结构 flat layout
        package_folder
        ├── README.md
        ├── package_name
        │   └── __init__.py
        │   └── __main__.py
        ├── pyproject.toml
        └── tests

        # 源码结构 src layout
        package_folder
        ├── README.md
        ├── src
        |   └── package_name
        |       └── __init__.py
        |       └── __main__.py
        ├── pyproject.toml
        └── tests

Python 作为一门脚本解释语言，包跟程序两者之间的差异几乎没有，不像编译型语言一样严格区分，注重程序入口。所以任意 Python 项目采取上述两种结构中的一种即可，两种的区别可以参考[官方文档](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/)。采用标准结构的好处在于，其对于打包友好，使用像 poetry 这样的包构建工具可以屏蔽大部分细节，渐进式的去学习使用打包，本身打包也是一个比较复杂的问题。新人可以按照基本的通史去入手项目，同时 pip 安装包支持直接从仓库源码安装构建，pip install git+ssh://git@repo.com/pacage.git 这样就行，方便那些不能上传 PyPi 的项目。

无论是编写程序还是库，都应该按照编写库 API 标准一样要求自己。很多私有项目往往会有自己的一套依赖管理“解决方案”，这实际上多少有点“草台班子”。其一是选择官方这套包管理生态，无疑后续相关工具或者大部分功能都已是现成，借势而为才能更省力。其二是，软件开发实际上本就是个分布式模型，不同的代码交给不同的人分工协作，这些代码可能随时修改更新破坏兼容性，每个代码部分都尽量去做到模块化，提升可被二次复用分发的价值，减少对依赖项目的牵连影响。

## Python 工具链

### 虚拟环境 & 依赖管理 & 打包管理 poetry
pyproject.toml 是 现代 Python 项目定义项目元数据的地方。它看起来像是下面这个样子：

        [tool.poetry]
        name = "project"
        version = "1.1.0"
        description = "An Example Project"
        authors = ["sunkaiyuan <sunkaiyuan@corp.netease.com>"]
        readme = "README.md"

        [tool.poetry.dependencies]
        python = "^3.10"
        argcomplete = "^3.0.0"
        psutil = "^5.9.4"
        rich = "^12.5.1"

        [tool.poetry.group.dev.dependencies]
        debugpy = "^1.6.3"
        pytest = "^7.1.3"
        black = "^22.8.0"
        pre-commit = "^2.20.0"
        mypy = "^0.971"
        isort = "^5.10.1"

        [tool.black]
        include = '\.pyi?$'
        line-length = 120

        [build-system]
        requires = ["poetry-core"]
        build-backend = "poetry.core.masonry.api"

        [tool.poetry.scripts]
        cli = "project.__main__:cli"

简单看来，它是一个声明式的 TOML 配置文件。从上往下描述了项目的基本信息、项目依赖包、开发依赖包、代码格式化设置、包构建系统、命令行脚本工具入口。当然这只是 poetry 作为主要包管理工具的样子，根据这些元数据，poetry 这样的工具可以帮你自动管理安装依赖、构建发行包。通过标准的一个 poetry install 命令，作为开发入口简单的第一步，避免过往过程中各种磕磕碰碰的小问题。详细使用可以参考 poetry 的[官方教程](https://python-poetry.org/docs/basic-usage/)。

这里有两个值得一提的地方，一个是依赖项后面的版本号，理论上应该遵循[语义化版本](https://semver.org/lang/zh-CN/)的原则，简单来说就是分为主版本、小版本、修订版本三部分，有不兼容修改应该递增主版本号、有新功能加入应该递增小版本、功能修复应该递增修订版本。另一个是配置文件最后一项 `tool.poetry.scripts`，其作用是，当别人 pip 安装了你的包之后，其 Shell 环境中会自动多一个叫做 cli 的命令行脚本，它被调用时会执行 project 包中 __main__.py 文件中的 cli 函数，详细的 feature 介绍可以查看 setuptools 的[功能介绍](https://setuptools.pypa.io/en/latest/userguide/entry_point.html)，叫做 entry point。

### 解释器版本管理 pyenv
在 Linux 下管理 Python 环境，绝逼是一件蛋疼的事情。脚本中的无数 python 都假定它们指向是“理想”中的那个版本，可惜理想之间终究是有矛盾的。pyenv 便是一种“理想”隔离装置，原理是利用环境变量拦下调用，从而指向不同版本的 Python。它可以帮你安装 Python，可以修改全局 Python 版本，可以修改局部文件夹下 Python 版本。在编写 Dockerfile 的时候也拿来装一下 Python，大概流程像是下面那样，详细使用可以参考[官方文档](https://github.com/pyenv/pyenv)，跟 Shell 相关，实际上对 Linux 新手来说还是有点麻烦的。

        ARG PYTHON_VERSION=3.11.1
        ENV PYENV_ROOT="${HOME}/.pyenv"
        # pyenv path
        ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${HOME}/.local/bin:$PATH"
        # pyenv install
        RUN curl https://pyenv.run | bash \
                && pyenv install ${PYTHON_VERSION} \
                && pyenv global ${PYTHON_VERSION}

### 隔离命令行入口 pipx
这个工具是为了上面 poetry 一节最后说的 entry point 设计的。笔者曾经以此方式编写一个命令行工具，使用的同事则拒绝安装使用，原因是这会搞乱他的全局 pip 环境，而使用虚拟环境隔绝 Python 环境会有一个问题，那就是命令行脚本入口也随着一起被隔离，使用的需要先去切虚拟环境。pipx 可以在创建隔离虚拟环境的同时，将命令行脚本入口暴露到全局环境中。无论是同个工具同时使用多个版本或者是不同工具环境互斥都不用担心了，尽情使用 Python 去丰富终端生活吧。

### 代码格式化 black
一千个人眼里有一千个哈姆雷特。程序可不希望一个代码仓库中同一个代码结构有一千种写法，为了可读性，调节空格换行节距实际上是一个挺琐碎的事情。项目之间不同的风格约定，以及只认纯文本的版本管理工具加入更是加剧了格式化这恼人的一面，特别是 Python 是一门需要游标卡尺的语言，还允许自由使用空格或是制表符作为缩进，一些工具甚至不能在制表符的情况下正常工作。Black 的简介是 The Uncompromising Code Formatter，”毫不妥协“，只提供极少配置选项给用户，减少在这些琐事上的研究浪费。就像 Python 仁慈的独裁者一样，在代码格式化这件事上，还是独裁一点好。

### 代码提交挂钩 pre-commit
pre-commit 可以在 git 提交之前检查提交的文件，并对其中不合规的部分进行改写，此时提交者需要重新审阅修改并添加修改，知道检查全部通过才会提交成功。一般配合代码格式化一起使用。

### 静态代码检查 mypy
typehint 是 Python3 最重要的更新之一，尽管有人会问，在动态语言里面追求静态类型检查是不是搞错了什么？额，在这个问题上，大家一直非常分裂。有实用主义者，追求不管标注是不是正确，IDE 能正确识别给出提示就算成功。有保守纯粹者，认为 typehint 只应该是标注提示，不该对运行时产生影响，降低效率。有激进改革者，代码运行时提取类型信息，强制对运行时数据进行类型检查。个人认为，适当在简单情形下在 API 上添加类型注释或者是描述数据结构 Scheme 就好，配合代码补全体验已经相当友好，使用 mypy 在一些判空处理的情境下提示也能避免低级错误。

### 调试与测试 debugpy、pytest
解释型脚本，debugpy 调试起来很方便，开发命令行工具的情况下写个 --debug 选项，跟 vscode 一起用起来很贴心，远程调试、API接口、wait_for_client 该有的功能都有。动态语言，不够健壮，靠完备的测试也可以保证像静态语言一样健壮。曾经有人言，写代码不写单元测试就像是上厕所不洗手，前提是时间足够的情况下。

## VScode 拓展与设置
使用 VScode，首先需要熟悉一下其常用的 feature 与打开方式，以便更好地使用它。
- 丰富的插件生态
- 命令行面板
- 自定义快捷键
- 配置化的任务调试启动流
- 终端与版本控制工具集成
- 远程开发

### 基础设置
首先来介绍一些 VScode 常用设定。
- 一个命令行面板（快捷键 Ctrl + Shift + P），内置与插件大部分功能函数都可以通过命令面板找到。
- 可以通过快捷键面板（快捷键 Ctrl + K、Ctrl + S）通过描述查找自己需要的快捷键，并自定义。命令行面板中的命令都可以绑定快捷键。
- 用户配置数据通常都保存成 json 格式的配置文件。配置文件有优先级之分，例如工作区 .vscode 文件夹里面 setting.json 比全局 setting.json 优先级要高。

所以，如果你忘记一个快捷键按键是什么，可以打开命令行面板通过描述来查找它，旁边则会提示你它绑定的快捷键。如果你想自定义自己的 VScode 体验，只需要打开配置文件按配置项更改即可，无论是快捷键还是设置项。如果你不知道有哪些可配置项，可以打开命令行面板，输入 `open default` 这个关键字，即可查看默认的快捷键及设置项有哪些是什么值。同时，插件大部分功能都可以在拓展商店主页，点击 `功能贡献` 进行审阅。强大而一致的体验，降低使用门槛，方便入手。

IDE 注重专用环境下的用途，编辑器则注重通用环境下的编辑。VScode 想两者都要，注重的是提供一个如上面设定一般强大且通用的机制。但通用毕竟不能做到专业的那么面面俱到，往往需要用户写一些中间配置才能用的比较顺畅。 `.vscode/launch.json`、`.vscode/tasks.json` 两个文件便是做这件事的，前者用来配置调试信息，后者用来配置项目中的自定义任务，如编写编译型语言，需要先进行编译任务，再启动调试。其中有一些琐碎的细节，比如后者 tasks 可以定义一个 Problem Matcher，用于像编译报错这种情况下，将警告报错放到编辑器中显示提示，其他的比如配置调试器路径。新手按照文档一步一步配就好，开发过程中热更、导表之类的自动化流程都可以配在里面，提升效率。

### Python 开发相关设置
VScode 开发 Python 使用的插件主要就是 Python 及 Pylance，根据最新的[官方指南](https://aka.ms/AAlgvkb)，再根据需要使用的功能针对性安装插件。基本上只要在打开 py 文件后，在右下角的状态栏选择合适版本的 Python 就好。Pylance 也能打开一些辅助设置，显示更多辅助信息，内联显示推导出来的类型以及参数名称。同时 Pylance 其实会为代码中的词法元素打 Tag，颜色主题可以根据这些 Tag，去更改显示颜色，增加区分度。

        # 语义着色
        "editor.semanticTokenColorCustomizations": {
            "enabled": true,
            "rules": {
                "*.decorator:python": "#1495ff",
                 "*.typeHint:python": "#8241c4",
                }
        },
        # 提升检查等级
        "python.analysis.typeCheckingMode": "basic",
        # 内嵌显示
        "python.analysis.inlayHints.functionReturnTypes": true,
        "python.analysis.inlayHints.variableTypes": true,
        "python.analysis.inlayHints.callArgumentNames": true,

### 插件推荐
- `autoDocstring` 自动生成多种风格 python docstring 注释，统一注释风格有助于后续的文档导出
- `Error Lens` 静态代码检查跟在编辑器对应行后面，可以及时注意到错误，因为一般问题这个标签页都是收起来的
- `Log Viewer` tail -f 看 log 的乐趣
- `Bookmarks` 标记文件修改位置，快速跳转
- `Jump` 让光标快速跳转到想去的地方
- `Bracket Select` 根据配对的语法符号快速选中
- `Git Graph` 下面终端敲命令，上面页签看分支图
- `Gitlens` 方便 Git 代码审阅

## DevContainer 统一开发环境
VScode 的杀手级特性之一便是远程开发，无论开发环境在远端 Linux、本地 Windows 的 WSL下亦或是 Docker 里面，都可以获得跟本地开发近乎一致的体验。

DevContainer 是什么呢？首先要来了解一下 Docker 是什么？Docker 是 Linux 下一种轻量级的“虚拟化”技术，为应用程序提供一个相对隔离的运行环境，运用 Docker 可以做到很大程度上的运行时环境可移植，其也是采取声明式配置的方式定义运行环境，可以跟源代码加入同个版本控制仓库管理。DevContainer 既是将开发环境作为容器，作为可移植的开发环境，让每位开发者都得到一致的体验。

所以为什么要在容器下面开发呢？一般来说有以下好处：
- 一致的运行时工具链版本，不必因为版本不一致而导致烦恼，比如不同版本的代码格式化行为可能有些许不同，导表工具链只在 py3.11 上工作而 py3.6 一下则会直接失败。
- 标准化的开发流程、减低了入手门槛，不必一开始先本地搭建环境对版本折腾半天，文档上面的流程可能已经有些过时，而容器环境是跟代码一起管理的，具有可移植性。
- 隔离化的开发环境，可以快速在多个开发环境中进行切换，而无需担心相互之间产生冲突干扰，避免上面 pyenv 所面临一样的问题。
- 真正的云端编程，与 Github CodeSpace 一起使用，开发环境将由云端创建，而可以在任何终端上基于 Web 或者是 VScode 客户端进行远程开发。

同时 Windows 上使用 WSL 进行开发，可以在 Windows 与 Linux 上访问同一份文件，两边操作系统的工具都可以取其长处使用。对于跨端需要 C/S 共享部分数据开发十分友好。

VScode 开发容器支持了此功能，只需编写 .devcontainer/devcontainer.json 且具有 Docker 环境即可一键在容器中打开工程项目，得到一致的开发体验。而在 Windows 上一样可以具有 Docker 环境，只需要安装上 Docker Desktop 或 Rancher Desktop；或者只要安装上 WSL 里面有个 Docker，再将 vscode 配置项 dev.containers.executeInWSL 置为 true 即可，跟前面的本质上是一样的。具体配置使用可以参照 VScode [官方文档](https://code.visualstudio.com/docs/devcontainers/containers)，还有一个专门的[页面](https://containers.dev/)介绍。