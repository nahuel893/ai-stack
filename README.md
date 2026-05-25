# 🤖 AI Agent CLI Installer

An elegant, interactive, and robust terminal installation assistant designed to deploy, configure, and manage the most powerful AI coding agents and development harnesses on Linux and macOS.

```
┌────────────────────────────────────────────────────────┐
│             🤖  AI AGENT CLI INSTALLER  🤖             │
└────────────────────────────────────────────────────────┘
```

---

## ✨ Features

- 🎨 **Visual Terminal Interface**: Beautiful ANSI-styled console layouts, bold headers, and micro-styled status markers.
- ⠋ **Polished Loading Indicators**: Dynamic braille spinners displaying live progress during agent downloads and installations.
- ⚙️ **Automatic Dependency Checks**: Automatic diagnostics for prerequisites like `curl`, `git`, `npm`, and `pipx`.
- 🕹️ **Interactive Selection Menu**: TUI selector where you can toggle agents/tools dynamically.
- 🤖 **Non-interactive / Headless Mode**: Full support for flags (e.g. `--yes`, `--all`) to allow seamless automation, scripting, and CI/CD pipelines.
- 🔍 **Safe Simulated Executions**: Support for `--dry-run` to inspect commands before executing changes on your system.

---

## 🚀 Supported Agents & Tools

| Agent / Tool | Binary Name | Description | Installation Method |
| :--- | :--- | :--- | :--- |
| **Claude Code** | `claude` | Anthropic's official high-speed agentic coder | `curl` native script |
| **Antigravity CLI** | `agy` | Google's advanced terminal agent (asynchronous subagents) | `curl` native script |
| **OpenCode** | `opencode` | Open-source, provider-agnostic TUI coding agent | `curl` native script |
| **Gentle-AI** | `gentle-ai` | SDD orchestrator, agent memory harness & curated skills | GitHub script |
| **Qwen Code** | `qwen` | Qwen's official CLI coding agent | Curl installation script |
| **Pi Coding Agent** | `pi` | Minimalist open-source CLI coding agent | Curl installation script |
| **Aider** | `aider` | High-fidelity terminal pair-programming coder | `pipx` / `pip3` |
| **Open Interpreter**| `interpreter`| Conversational CLI for running local machine code | `pipx` / `pip3` |

---

## 🛠️ Usage Instructions

Clone this repository and navigate to the directory:

```bash
git clone https://github.com/nahuel/ai-stack.git
cd ai-stack
```

Ensure the installer script is executable:

```bash
chmod +x install.sh
```

### 1. Interactive Mode (Recommended)
Simply execute the installer script without arguments. It will launch a beautiful TUI menu:

```bash
./install.sh
```

Within the interactive menu, you can toggle agents, verify your dependencies, and proceed with the installation of your selections.

### 2. Non-interactive Mode (Automated)
To install the **default recommended agents** (Claude Code, agy, OpenCode, Gentle-AI, Qwen Code, and Pi) silently:

```bash
./install.sh --yes
```

To install **all available tools** (including Aider and Open Interpreter):

```bash
./install.sh --all
```

To target a **specific combination of tools**:

```bash
./install.sh --claude --gentle-ai
```

### 3. Dry-Run Verification
To simulate the installation flow and inspect the exact commands that would be executed on your machine:

```bash
./install.sh --yes --dry-run
```

---

## 🏁 Quick Start & Authentication

Once installed, use the following commands to authenticate and begin using each tool:

### 1. Claude Code
Initialize and connect your Anthropic account:
```bash
claude auth login
```
*Note: Requires an active Claude Pro/Team subscription or Anthropic Console API credit.*

### 2. Antigravity CLI (agy)
Run to trigger the Google Sign-in authentication flow:
```bash
agy
```

### 3. OpenCode
Start the terminal interface and log in:
```bash
opencode auth login
```

### 4. Gentle-AI
Inject spec-driven development configurations, skills, and memory optimizations:
```bash
# Launch interactive TUI configuration
gentle-ai

# Or install configurations non-interactively
gentle-ai install --agent claude-code,opencode
```

### 5. Qwen Code
Launch the Qwen CLI agent:
```bash
qwen
```
*Note: Follow the on-screen configuration prompts during the first startup.*

### 6. Pi Coding Agent
Launch the Pi CLI agent:
```bash
pi
```
*Note: Run `pi` inside any project directory to initialize an agentic session.*

### 7. Aider
Export your API key and start coding:
```bash
export ANTHROPIC_API_KEY="your-key-here"
aider
```

### 8. Open Interpreter
Run locally to execute code:
```bash
interpreter
```

---

> [!TIP]
> **Recommended Workflow:** First, install **Claude Code**, **OpenCode**, and **Gentle-AI**. Then run `gentle-ai install` to configure spec-driven templates and persistent memory extensions directly onto Claude Code and OpenCode!

Enjoy building with your new suite of AI coding agents! 🚀
