#!/usr/bin/env bash

# ==============================================================================
#                  🤖  AI AGENT CLI INSTALLER  🤖
# ==============================================================================
# A beautiful, interactive, and robust script to install leading AI CLI agents.
# Supporting: Claude Code, Antigravity CLI (agy), OpenCode, Gentle-AI, Qwen Code, and others.
# ==============================================================================

set -euo pipefail

# --- Color Definitions (ANSI Escape Sequences) ---
CLR_ESC="\e["
CLR_RESET="${CLR_ESC}0m"
CLR_BOLD="${CLR_ESC}1m"
CLR_DIM="${CLR_ESC}2m"
CLR_ITALIC="${CLR_ESC}3m"
CLR_UNDERLINE="${CLR_ESC}4m"

# Palette
CLR_PRIMARY="${CLR_ESC}38;5;141m"   # Soft Purple
CLR_ACCENT="${CLR_ESC}38;5;39m"     # Bright Blue
CLR_SUCCESS="${CLR_ESC}38;5;82m"    # Vibrant Green
CLR_WARNING="${CLR_ESC}38;5;214m"   # Amber/Orange
CLR_ERROR="${CLR_ESC}38;5;196m"     # Red
CLR_INFO="${CLR_ESC}38;5;51m"       # Cyan
CLR_MUTED="${CLR_ESC}38;5;244m"     # Gray

# --- Icons ---
ICON_SUCCESS="${CLR_SUCCESS}✔${CLR_RESET}"
ICON_ERROR="${CLR_ERROR}✖${CLR_RESET}"
ICON_WARNING="${CLR_WARNING}⚠${CLR_RESET}"
ICON_INFO="${CLR_INFO}ℹ${CLR_RESET}"
ICON_PROMPT="${CLR_PRIMARY}➜${CLR_RESET}"
ICON_BULLET="${CLR_ACCENT}•${CLR_RESET}"

# --- State Variables ---
DRY_RUN=false
NON_INTERACTIVE=false
INSTALL_ALL=false

# Default selections
CHOSEN_CLAUDE=true
CHOSEN_AGY=true
CHOSEN_OPENCODE=true
CHOSEN_GENTLE_AI=true
CHOSEN_QWEN=true
CHOSEN_AIDER=false
CHOSEN_INTERPRETER=false

# --- Logging Helpers ---
log_header() {
    echo -e "\n${CLR_BOLD}${CLR_PRIMARY}┌────────────────────────────────────────────────────────┐${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_PRIMARY}│             🤖  AI AGENT CLI INSTALLER  🤖             │${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_PRIMARY}└────────────────────────────────────────────────────────┘${CLR_RESET}\n"
}

log_info() {
    echo -e " ${ICON_INFO} ${CLR_BOLD}${CLR_INFO}Info:${CLR_RESET} $1"
}

log_success() {
    echo -e " ${ICON_SUCCESS} ${CLR_BOLD}${CLR_SUCCESS}Success:${CLR_RESET} $1"
}

log_warning() {
    echo -e " ${ICON_WARNING} ${CLR_BOLD}${CLR_WARNING}Warning:${CLR_RESET} $1"
}

log_error() {
    echo -e " ${ICON_ERROR} ${CLR_BOLD}${CLR_ERROR}Error:${CLR_RESET} $1" >&2
}

log_step() {
    echo -e "\n${CLR_BOLD}${CLR_ACCENT}❯ $1${CLR_RESET}"
}

log_bullet() {
    echo -e "   ${ICON_BULLET} $1"
}

# --- Spinner Helper ---
run_with_spinner() {
    local message="$1"
    shift
    local cmd=("$@")

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CLR_MUTED}[Dry-Run] Would run: ${cmd[*]}${CLR_RESET}"
        return 0
    fi

    # Run the command in the background, redirecting stdout/stderr to a temporary file
    local tmp_log
    tmp_log=$(mktemp)
    
    # Start the command
    "${cmd[@]}" > "$tmp_log" 2>&1 &
    local pid=$!

    # Spinner animation
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local delay=0.08
    
    while kill -0 "$pid" 2>/dev/null; do
        for i in "${spin[@]}"; do
            printf "\r  ${CLR_PRIMARY}%s${CLR_RESET} %s..." "$i" "$message"
            sleep "$delay"
            if ! kill -0 "$pid" 2>/dev/null; then
                break
            fi
        done
    done

    # Get the exit code
    wait "$pid" && local exit_code=0 || local exit_code=$?
    
    # Clear the spinner line
    printf "\r\033[K"

    if [ "$exit_code" -eq 0 ]; then
        log_success "$message completed successfully."
        rm -f "$tmp_log"
        return 0
    else
        log_error "$message failed (Exit code: $exit_code)."
        echo -e "${CLR_RED}----- Command Output -----${CLR_RESET}"
        cat "$tmp_log"
        echo -e "${CLR_RED}--------------------------${CLR_RESET}"
        rm -f "$tmp_log"
        return "$exit_code"
    fi
}

# --- Show Help ---
show_help() {
    echo -e "${CLR_BOLD}AI Agent CLI Installer${CLR_RESET}"
    echo -e "Usage: ./install.sh [options]\n"
    echo -e "Options:"
    echo -e "  -y, --yes          Non-interactive mode, installs core agents (Claude, agy, OpenCode, Gentle-AI, Qwen Code)"
    echo -e "  -a, --all          Non-interactive mode, installs all available agents/tools"
    echo -e "  --claude           Select Claude Code for installation"
    echo -e "  --agy              Select Antigravity CLI (agy) for installation"
    echo -e "  --opencode         Select OpenCode for installation"
    echo -e "  --gentle-ai        Select Gentle-AI for installation"
    echo -e "  --qwen             Select Qwen Code for installation"
    echo -e "  --aider            Select Aider for installation"
    echo -e "  --interpreter      Select Open Interpreter for installation"
    echo -e "  --dry-run          Run script in dry-run mode, printing actions without executing them"
    echo -e "  -h, --help         Display this help message and exit"
    echo -e "\nIf no flags are provided, the script runs in interactive mode."
}

# --- Parse Arguments ---
parse_args() {
    # If arguments are provided, default all selections to false unless specified
    if [ "$#" -gt 0 ]; then
        # Check if only dry-run is specified
        local has_selection_flag=false
        for arg in "$@"; do
            if [[ "$arg" =~ ^--(claude|agy|opencode|gentle-ai|qwen|aider|interpreter)$ ]] || [ "$arg" = "-a" ] || [ "$arg" = "--all" ] || [ "$arg" = "-y" ] || [ "$arg" = "--yes" ]; then
                has_selection_flag=true
                break
            fi
        done
        
        if [ "$has_selection_flag" = true ]; then
            CHOSEN_CLAUDE=false
            CHOSEN_AGY=false
            CHOSEN_OPENCODE=false
            CHOSEN_GENTLE_AI=false
            CHOSEN_QWEN=false
            CHOSEN_AIDER=false
            CHOSEN_INTERPRETER=false
        fi
    fi

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -y|--yes)
                NON_INTERACTIVE=true
                CHOSEN_CLAUDE=true
                CHOSEN_AGY=true
                CHOSEN_OPENCODE=true
                CHOSEN_GENTLE_AI=true
                CHOSEN_QWEN=true
                shift
                ;;
            -a|--all)
                NON_INTERACTIVE=true
                INSTALL_ALL=true
                CHOSEN_CLAUDE=true
                CHOSEN_AGY=true
                CHOSEN_OPENCODE=true
                CHOSEN_GENTLE_AI=true
                CHOSEN_QWEN=true
                CHOSEN_AIDER=true
                CHOSEN_INTERPRETER=true
                shift
                ;;
            --claude)
                NON_INTERACTIVE=true
                CHOSEN_CLAUDE=true
                shift
                ;;
            --agy)
                NON_INTERACTIVE=true
                CHOSEN_AGY=true
                shift
                ;;
            --opencode)
                NON_INTERACTIVE=true
                CHOSEN_OPENCODE=true
                shift
                ;;
            --gentle-ai)
                NON_INTERACTIVE=true
                CHOSEN_GENTLE_AI=true
                shift
                ;;
            --qwen)
                NON_INTERACTIVE=true
                CHOSEN_QWEN=true
                shift
                ;;
            --aider)
                NON_INTERACTIVE=true
                CHOSEN_AIDER=true
                shift
                ;;
            --interpreter)
                NON_INTERACTIVE=true
                CHOSEN_INTERPRETER=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# --- Verify System Prerequisites ---
check_prerequisites() {
    log_step "Checking System Prerequisites"
    
    local missing_deps=()
    
    # Essential dependencies
    for dep in curl git; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing essential tools: ${missing_deps[*]}"
        log_info "Please install them before running this script again."
        log_info "On Debian/Ubuntu: sudo apt update && sudo apt install -y ${missing_deps[*]}"
        exit 1
    else
        log_success "All essential tools (curl, git) are available."
    fi

    # Check for package managers if Aider or Interpreter are chosen
    if [ "$CHOSEN_AIDER" = true ] || [ "$CHOSEN_INTERPRETER" = true ]; then
        if ! command -v pipx &>/dev/null; then
            log_warning "pipx is required to install python-based agents (Aider / Open Interpreter)."
            log_info "We will attempt to use 'pip' if 'pipx' is unavailable, but pipx is highly recommended."
            
            if ! command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
                log_error "Neither pipx nor pip is installed. Cannot install python-based agents."
                log_info "To install pipx on Debian/Ubuntu: sudo apt install -y pipx && pipx ensurepath"
                log_info "Alternatively, deselect Aider and Open Interpreter."
                
                if [ "$NON_INTERACTIVE" = true ]; then
                    log_error "Exiting due to missing dependencies in non-interactive mode."
                    exit 1
                else
                    echo -e "\nPress ENTER to return to the menu..."
                    read -r _
                    return 1
                fi
            fi
        fi
    fi
    
    return 0
}

# --- Interactive Selector Menu ---
interactive_menu() {
    local choice
    while true; do
        clear
        log_header
        
        echo -e "${CLR_BOLD}Select the CLI AI Agents / Tools you want to install:${CLR_RESET}\n"
        
        local check_claude="[ ]"
        local check_agy="[ ]"
        local check_opencode="[ ]"
        local check_gentle="[ ]"
        local check_qwen="[ ]"
        local check_aider="[ ]"
        local check_interpreter="[ ]"
        
        [ "$CHOSEN_CLAUDE" = true ] && check_claude="[${CLR_SUCCESS}✔${CLR_RESET}]"
        [ "$CHOSEN_AGY" = true ] && check_agy="[${CLR_SUCCESS}✔${CLR_RESET}]"
        [ "$CHOSEN_OPENCODE" = true ] && check_opencode="[${CLR_SUCCESS}✔${CLR_RESET}]"
        [ "$CHOSEN_GENTLE_AI" = true ] && check_gentle="[${CLR_SUCCESS}✔${CLR_RESET}]"
        [ "$CHOSEN_QWEN" = true ] && check_qwen="[${CLR_SUCCESS}✔${CLR_RESET}]"
        [ "$CHOSEN_AIDER" = true ] && check_aider="[${CLR_SUCCESS}✔${CLR_RESET}]"
        [ "$CHOSEN_INTERPRETER" = true ] && check_interpreter="[${CLR_SUCCESS}✔${CLR_RESET}]"
        
        echo -e "  ${CLR_BOLD}1)${CLR_RESET} $check_claude Claude Code      ${CLR_MUTED}(Anthropic's official terminal agent)${CLR_RESET}"
        echo -e "  ${CLR_BOLD}2)${CLR_RESET} $check_agy Antigravity CLI  ${CLR_MUTED}(agy - Google's terminal agent)${CLR_RESET}"
        echo -e "  ${CLR_BOLD}3)${CLR_RESET} $check_opencode OpenCode         ${CLR_MUTED}(Open-source provider-agnostic agent)${CLR_RESET}"
        echo -e "  ${CLR_BOLD}4)${CLR_RESET} $check_gentle Gentle-AI        ${CLR_MUTED}(AI harness, SDD configurator & memory booster)${CLR_RESET}"
        echo -e "  ${CLR_BOLD}5)${CLR_RESET} $check_qwen Qwen Code         ${CLR_MUTED}(Qwen's official CLI coding agent)${CLR_RESET}"
        echo -e "  ${CLR_BOLD}6)${CLR_RESET} $check_aider Aider            ${CLR_MUTED}(Popular coding pair programmer - requires pipx)${CLR_RESET}"
        echo -e "  ${CLR_BOLD}7)${CLR_RESET} $check_interpreter Open Interpreter ${CLR_MUTED}(Local code runner - requires pipx)${CLR_RESET}"
        echo -e ""
        echo -e "  ${CLR_BOLD}i)${CLR_RESET} Toggle All Default  ${CLR_MUTED}(Claude, agy, OpenCode, Gentle-AI, Qwen Code)${CLR_RESET}"
        echo -e "  ${CLR_BOLD}a)${CLR_RESET} Toggle All Tools"
        echo -e "  ${CLR_BOLD}d)${CLR_RESET} Run Dependency Check"
        echo -e ""
        echo -e "  ${CLR_BOLD}g)${CLR_RESET} ${CLR_BOLD}${CLR_SUCCESS}▶ PROCEED WITH INSTALLATION${CLR_RESET}"
        echo -e "  ${CLR_BOLD}q)${CLR_RESET} ${CLR_ERROR}Exit${CLR_RESET}\n"
        
        read -p "➜ Enter option (1-7, i, a, d, g, q): " choice
        
        case "$choice" in
            1) CHOSEN_CLAUDE=$([ "$CHOSEN_CLAUDE" = true ] && echo false || echo true) ;;
            2) CHOSEN_AGY=$([ "$CHOSEN_AGY" = true ] && echo false || echo true) ;;
            3) CHOSEN_OPENCODE=$([ "$CHOSEN_OPENCODE" = true ] && echo false || echo true) ;;
            4) CHOSEN_GENTLE_AI=$([ "$CHOSEN_GENTLE_AI" = true ] && echo false || echo true) ;;
            5) CHOSEN_QWEN=$([ "$CHOSEN_QWEN" = true ] && echo false || echo true) ;;
            6) CHOSEN_AIDER=$([ "$CHOSEN_AIDER" = true ] && echo false || echo true) ;;
            7) CHOSEN_INTERPRETER=$([ "$CHOSEN_INTERPRETER" = true ] && echo false || echo true) ;;
            i)
                if [ "$CHOSEN_CLAUDE" = true ] && [ "$CHOSEN_AGY" = true ] && [ "$CHOSEN_OPENCODE" = true ] && [ "$CHOSEN_GENTLE_AI" = true ] && [ "$CHOSEN_QWEN" = true ]; then
                    CHOSEN_CLAUDE=false; CHOSEN_AGY=false; CHOSEN_OPENCODE=false; CHOSEN_GENTLE_AI=false; CHOSEN_QWEN=false
                else
                    CHOSEN_CLAUDE=true; CHOSEN_AGY=true; CHOSEN_OPENCODE=true; CHOSEN_GENTLE_AI=true; CHOSEN_QWEN=true
                fi
                ;;
            a)
                if [ "$CHOSEN_CLAUDE" = true ] && [ "$CHOSEN_AGY" = true ] && [ "$CHOSEN_OPENCODE" = true ] && [ "$CHOSEN_GENTLE_AI" = true ] && [ "$CHOSEN_QWEN" = true ] && [ "$CHOSEN_AIDER" = true ] && [ "$CHOSEN_INTERPRETER" = true ]; then
                    CHOSEN_CLAUDE=false; CHOSEN_AGY=false; CHOSEN_OPENCODE=false; CHOSEN_GENTLE_AI=false; CHOSEN_QWEN=false; CHOSEN_AIDER=false; CHOSEN_INTERPRETER=false
                else
                    CHOSEN_CLAUDE=true; CHOSEN_AGY=true; CHOSEN_OPENCODE=true; CHOSEN_GENTLE_AI=true; CHOSEN_QWEN=true; CHOSEN_AIDER=true; CHOSEN_INTERPRETER=true
                fi
                ;;
            d)
                set +e
                check_prerequisites
                set -e
                echo -e "\nPress ENTER to return..."
                read -r _
                ;;
            g)
                # Verify we selected at least one
                if [ "$CHOSEN_CLAUDE" = false ] && [ "$CHOSEN_AGY" = false ] && [ "$CHOSEN_OPENCODE" = false ] && [ "$CHOSEN_GENTLE_AI" = false ] && [ "$CHOSEN_QWEN" = false ] && [ "$CHOSEN_AIDER" = false ] && [ "$CHOSEN_INTERPRETER" = false ]; then
                    log_warning "No tools selected. Please select at least one item to install."
                    sleep 2
                else
                    # Perform final prerequisite check before proceeding
                    set +e
                    if check_prerequisites; then
                        set -e
                        break
                    fi
                    set -e
                fi
                ;;
            q)
                log_info "Exiting. No changes made."
                exit 0
                ;;
            *)
                log_warning "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

# --- Installers ---
install_claude() {
    log_step "Installing Claude Code..."
    # The official script runs curl -fsSL https://claude.ai/install.sh | bash
    run_with_spinner "Downloading and executing Claude Code installer" bash -c "curl -fsSL https://claude.ai/install.sh | bash"
}

install_agy() {
    log_step "Installing Antigravity CLI (agy)..."
    # Canonical: curl -fsSL https://antigravity.google/cli/install.sh | bash
    run_with_spinner "Downloading and executing Antigravity CLI installer" bash -c "curl -fsSL https://antigravity.google/cli/install.sh | bash"
}

install_opencode() {
    log_step "Installing OpenCode..."
    # Canonical: curl -fsSL https://opencode.ai/install | bash
    run_with_spinner "Downloading and executing OpenCode installer" bash -c "curl -fsSL https://opencode.ai/install | bash"
}

install_gentle_ai() {
    log_step "Installing Gentle-AI..."
    # Canonical: curl -sSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
    run_with_spinner "Downloading and executing Gentle-AI installer" bash -c "curl -sSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash"
}

install_qwen() {
    log_step "Installing Qwen Code..."
    # Canonical: bash -c "$(curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen.sh)" -s --source qwenchat
    run_with_spinner "Downloading and executing Qwen Code installer" bash -c 'bash -c "$(curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen.sh)" -s --source qwenchat'
}

install_aider() {
    log_step "Installing Aider..."
    if command -v pipx &>/dev/null; then
        run_with_spinner "Installing Aider pair programmer via pipx" pipx install aider-chat
    else
        local pip_cmd="pip3"
        command -v pip &>/dev/null && pip_cmd="pip"
        run_with_spinner "Installing Aider pair programmer via pip (user-level)" "$pip_cmd" install --user aider-chat
    fi
}

install_interpreter() {
    log_step "Installing Open Interpreter..."
    if command -v pipx &>/dev/null; then
        run_with_spinner "Installing Open Interpreter via pipx" pipx install open-interpreter
    else
        local pip_cmd="pip3"
        command -v pip &>/dev/null && pip_cmd="pip"
        run_with_spinner "Installing Open Interpreter via pip (user-level)" "$pip_cmd" install --user open-interpreter
    fi
}

# --- Main Logic ---
main() {
    parse_args "$@"
    
    if [ "$NON_INTERACTIVE" = false ]; then
        interactive_menu
    else
        log_header
        log_info "Running in non-interactive mode."
        check_prerequisites
    fi

    log_step "Beginning installation for selected agents/tools"
    [ "$CHOSEN_CLAUDE" = true ] && log_bullet "Claude Code"
    [ "$CHOSEN_AGY" = true ] && log_bullet "Antigravity CLI (agy)"
    [ "$CHOSEN_OPENCODE" = true ] && log_bullet "OpenCode"
    [ "$CHOSEN_GENTLE_AI" = true ] && log_bullet "Gentle-AI"
    [ "$CHOSEN_QWEN" = true ] && log_bullet "Qwen Code"
    [ "$CHOSEN_AIDER" = true ] && log_bullet "Aider Pair Programmer"
    [ "$CHOSEN_INTERPRETER" = true ] && log_bullet "Open Interpreter"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN MODE ENABLED. No software will be actually installed."
    fi

    # Run installers
    [ "$CHOSEN_CLAUDE" = true ] && install_claude
    [ "$CHOSEN_AGY" = true ] && install_agy
    [ "$CHOSEN_OPENCODE" = true ] && install_opencode
    [ "$CHOSEN_GENTLE_AI" = true ] && install_gentle_ai
    [ "$CHOSEN_QWEN" = true ] && install_qwen
    [ "$CHOSEN_AIDER" = true ] && install_aider
    [ "$CHOSEN_INTERPRETER" = true ] && install_interpreter

    # --- Print Post-Installation Report ---
    echo -e "\n${CLR_BOLD}${CLR_SUCCESS}┌────────────────────────────────────────────────────────┐${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_SUCCESS}│             🚀  INSTALLATION COMPLETE!  🚀            │${CLR_RESET}"
    echo -e "${CLR_BOLD}${CLR_SUCCESS}└────────────────────────────────────────────────────────┘${CLR_RESET}\n"
    
    log_success "Congratulations! Your selected AI tools/agents are ready to be used or initialized."
    echo -e "\n${CLR_BOLD}Quick Start & Authentication Instructions:${CLR_RESET}"

    if [ "$CHOSEN_CLAUDE" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}1. Claude Code${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}claude${CLR_RESET}"
        log_bullet "Authenticate by running: ${CLR_CYAN}claude auth login${CLR_RESET}"
        log_bullet "Note: Requires a Claude Pro/Team account or Console API billing configured."
    fi

    if [ "$CHOSEN_AGY" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}2. Antigravity CLI (agy)${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}agy${CLR_RESET}"
        log_bullet "Start and authenticate by running: ${CLR_CYAN}agy${CLR_RESET}"
        log_bullet "Note: Initiates Google Sign-in flow automatically on first execution."
    fi

    if [ "$CHOSEN_OPENCODE" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}3. OpenCode${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}opencode${CLR_RESET}"
        log_bullet "Authenticate by launching TUI or running: ${CLR_CYAN}opencode auth login${CLR_RESET}"
        log_bullet "Note: Supports custom model endpoints and multiple providers."
    fi

    if [ "$CHOSEN_GENTLE_AI" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}4. Gentle-AI${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}gentle-ai${CLR_RESET}"
        log_bullet "Run first-time setup and config: ${CLR_CYAN}gentle-ai install${CLR_RESET}"
        log_bullet "Alternatively, launch the TUI for setup by simply running: ${CLR_CYAN}gentle-ai${CLR_RESET}"
        log_bullet "Sync configurations anytime: ${CLR_CYAN}gentle-ai sync${CLR_RESET}"
    fi

    if [ "$CHOSEN_QWEN" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}5. Qwen Code${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}qwen${CLR_RESET}"
        log_bullet "Launch Qwen CLI coding agent by running: ${CLR_CYAN}qwen${CLR_RESET}"
        log_bullet "Note: Follow on-screen instructions during the first run to complete setup."
    fi

    if [ "$CHOSEN_AIDER" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}6. Aider${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}aider${CLR_RESET}"
        log_bullet "Start inside any git repo by configuring your API key (e.g. export ANTHROPIC_API_KEY=...) and running: ${CLR_CYAN}aider${CLR_RESET}"
    fi

    if [ "$CHOSEN_INTERPRETER" = true ]; then
        echo -e "\n ${CLR_BOLD}${CLR_PRIMARY}7. Open Interpreter${CLR_RESET}"
        log_bullet "Command: ${CLR_BOLD}interpreter${CLR_RESET}"
        log_bullet "Start by running: ${CLR_CYAN}interpreter${CLR_RESET}"
    fi

    echo -e "\n${CLR_BOLD}${CLR_MUTED}Thank you for using the AI Agent CLI Installer! Keep exploring! 🚀${CLR_RESET}\n"
}

main "$@"
