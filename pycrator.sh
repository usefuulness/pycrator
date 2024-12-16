#!/bin/bash

# =============================================================================
# Ultimate Python Package Creation Script
# =============================================================================
# This script automates the setup of a new Python package with extensive
# customization options, including build systems, project layouts, GitHub
# integration, CI setup, dependency management, and more.
# =============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

# =============================================================================
# Global Variables
# =============================================================================
LOG_FILE="create_py_package.log"

# =============================================================================
# Function Definitions
# =============================================================================

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Function to display usage instructions
usage() {
    cat <<EOF
Usage: $0 <package_name> [options]

Options:
  --git                     Initialize a Git repository
  --remote <url>            Set remote repository URL
  --create-repo             Create a GitHub repository (requires GitHub CLI)
  --license <type>          Add a LICENSE file (e.g., MIT, Apache-2.0, GPL-3.0, BSD-3-Clause)
  --build-system <type>     Choose build system: setuptools (default) or poetry
  --layout <type>           Choose project layout: src (default) or direct
  --tests <framework>       Choose testing framework: unittest (default) or pytest
  --ci <service>            Set up Continuous Integration: github (default), travis, circleci
  --format <formatter>      Choose code formatter: black, autopep8, none (default)
  --lint <linter>           Choose linter: flake8, pylint, none (default)
  --docs                    Set up Sphinx documentation
  --env <tool>              Choose virtual environment tool: venv (default), virtualenv, poetry
  --python <version>        Specify Python version for virtual environment (default: 3)
  --help                    Display this help message

Examples:
  $0 my_package --git --create-repo --license MIT --build-system poetry --layout src --tests pytest --ci github --format black --lint flake8 --docs --env poetry --python 3.8
EOF
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    local deps=("python3" "curl" "git")
    for cmd in "${deps[@]}"; do
        if ! command_exists "$cmd"; then
            log "Error: '$cmd' is not installed. Please install it and retry."
            exit 1
        fi
    done

    if [ "$BUILD_SYSTEM" = "poetry" ] && ! command_exists "poetry"; then
        log "Error: 'poetry' is not installed. Please install it or choose a different build system."
        exit 1
    fi

    if [ "$CREATE_REPO" = true ] && ! command_exists "gh"; then
        log "Error: GitHub CLI 'gh' is not installed. Please install it or skip --create-repo."
        exit 1
    fi
}

# Function to fetch and create LICENSE file
fetch_license() {
    local license_type="$1"
    local year
    local fullname
    year=$(date +"%Y")
    fullname="$2"

    log "Fetching license: $license_type"

    case "$license_type" in
        MIT)
            LICENSE_URL="https://raw.githubusercontent.com/licenses/license-templates/master/templates/mit.txt"
            ;;
        Apache-2.0)
            LICENSE_URL="https://raw.githubusercontent.com/licenses/license-templates/master/templates/apache-2.0.txt"
            ;;
        GPL-3.0)
            LICENSE_URL="https://raw.githubusercontent.com/licenses/license-templates/master/templates/gpl-3.0.txt"
            ;;
        BSD-3-Clause)
            LICENSE_URL="https://raw.githubusercontent.com/licenses/license-templates/master/templates/bsd-3-clause.txt"
            ;;
        *)
            log "Unsupported license type: $license_type. Skipping LICENSE file."
            return
            ;;
    esac

    # Fetch the license text
    curl -s "$LICENSE_URL" | sed "s/\[year\]/$year/" | sed "s/\[fullname\]/$fullname/" > LICENSE
    log "LICENSE file created."
}

# Function to create project directories
create_directories() {
    local package="$1"
    local layout="$2"

    log "Creating project directory: $package"
    mkdir "$package" || { log "Failed to create directory $package"; exit 1; }

    if [ "$layout" = "src" ]; then
        log "Using 'src' layout."
        mkdir -p "$package/src/$package"
        touch "$package/src/$package/__init__.py"
    else
        log "Using direct layout."
        mkdir -p "$package/$package"
        touch "$package/$package/__init__.py"
    fi

    log "Creating tests directory."
    mkdir -p "$package/tests"
    touch "$package/tests/__init__.py"

    if [ "$TEST_FRAMEWORK" = "pytest" ]; then
        log "Setting up pytest sample test."
        cat > "$package/tests/test_sample.py" <<EOL
import pytest

def test_sample():
    assert True
EOL
    else
        log "Setting up unittest sample test."
        cat > "$package/tests/test_sample.py" <<EOL
import unittest

class TestSample(unittest.TestCase):
    def test_sample(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
EOL
    fi
}

# Function to create setup.py or pyproject.toml
create_build_files() {
    local package="$1"
    local build_system="$2"

    if [ "$build_system" = "poetry" ]; then
        log "Initializing Poetry project."
        poetry init --name "$package" --author "$AUTHOR_NAME <$AUTHOR_EMAIL>" --description "$DESCRIPTION" --python "^$PYTHON_VERSION" --dependency "" --dev-dependency "" -n

        # Additional configurations can be added here if needed
    else
        log "Creating setup.py using setuptools."
        cat > setup.py <<EOL
from setuptools import setup, find_packages

setup(
    name='$package',
    version='0.1.0',
    packages=find_packages('$PACKAGES_DIR'),
    package_dir={'': '$PACKAGES_DIR'},
    install_requires=[],
    author='$AUTHOR_NAME',
    author_email='$AUTHOR_EMAIL',
    description='$DESCRIPTION',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='$GITHUB_URL',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: $LICENSE_TYPE License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=$PYTHON_VERSION.0',
)
EOL
    fi
}

# Function to create README.md
create_readme() {
    local package="$1"

    log "Creating README.md."
    cat > README.md <<EOL
# $package

![License](https://img.shields.io/badge/license-$LICENSE_TYPE-blue.svg)

$DESCRIPTION

## Installation

\`\`\`bash
pip install $package
\`\`\`

## Usage

\`\`\`python
import $package

# Your code here
\`\`\`

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the $LICENSE_TYPE License - see the [LICENSE](LICENSE) file for details.
EOL
}

# Function to create .gitignore
create_gitignore() {
    log "Creating .gitignore."
    cat > .gitignore <<EOL
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Virtual environments
venv/
ENV/
env/
.venv/
.ENV/
.env/
env.bak/
venv.bak/

# Poetry
.poetry/

# Distribution / packaging
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/

# Sphinx documentation
docs/_build/

# IDEs and editors
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# MacOS
.DS_Store

# Logs
logs/
*.log

# Temporary files
tmp/
temp/
EOL
}

# Function to initialize Git repository
init_git() {
    log "Initializing Git repository."
    git init
    git add .
    git commit -m "Initial commit"
    log "Git repository initialized."
}

# Function to create virtual environment
create_virtualenv() {
    local env_tool="$1"
    local python_version="$2"

    if [ "$env_tool" = "poetry" ]; then
        log "Poetry handles the virtual environment."
    else
        log "Creating virtual environment using $env_tool with Python $python_version."
        if [ "$env_tool" = "virtualenv" ]; then
            virtualenv -p python"$python_version" venv
        else
            python"$python_version" -m venv venv
        fi
        log "Virtual environment created."
    fi
}

# Function to activate virtual environment
activate_virtualenv() {
    local env_tool="$1"

    if [ "$env_tool" = "poetry" ]; then
        log "Poetry manages the virtual environment."
    else
        log "Activating virtual environment."
        source venv/bin/activate
    fi
}

# Function to install dependencies in virtual environment
install_dependencies() {
    local env_tool="$1"
    local build_system="$2"

    if [ "$env_tool" = "poetry" ]; then
        log "Installing dependencies with Poetry."
        poetry install
    else
        log "Installing dependencies with pip."
        pip install --upgrade pip
        if [ "$build_system" = "setuptools" ]; then
            pip install -e .
        fi
    fi

    if [ "$FORMATTER" != "none" ]; then
        log "Installing formatter: $FORMATTER."
        pip install "$FORMATTER"
    fi

    if [ "$LINTER" != "none" ]; then
        log "Installing linter: $LINTER."
        pip install "$LINTER"
    fi

    if [ "$TEST_FRAMEWORK" = "pytest" ]; then
        log "Installing pytest."
        pip install pytest
    fi

    log "Dependencies installed."
}

# Function to set up pre-commit hooks
setup_precommit() {
    log "Setting up pre-commit hooks."
    pip install pre-commit
    pre-commit install

    cat > .pre-commit-config.yaml <<EOL
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
        language_version: python$PYTHON_VERSION
  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
EOL

    pre-commit install
    log "Pre-commit hooks configured."
}

# Function to set up Sphinx documentation
setup_sphinx() {
    log "Setting up Sphinx documentation."
    if [ "$BUILD_SYSTEM" = "poetry" ]; then
        poetry add --dev sphinx
    else
        pip install sphinx
    fi

    sphinx-quickstart docs --project="$PACKAGE_NAME" --author="$AUTHOR_NAME" --release="0.1.0" --no-interactive
    log "Sphinx documentation initialized."
}

# Function to set up Continuous Integration
setup_ci() {
    local service="$1"

    case "$service" in
        github)
            log "Setting up GitHub Actions for CI."
            mkdir -p .github/workflows
            cat > .github/workflows/python-package.yml <<EOL
name: Python package

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:

    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: [${PYTHON_VERSION}, 3.8, 3.9, 3.10]

    steps:
    - uses: actions/checkout@v2
    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        ${INSTALL_COMMAND}
    - name: Lint with flake8
      run: |
        $LINTER .
    - name: Test with pytest
      run: |
        $TEST_RUN_COMMAND
EOL
            ;;
        travis)
            log "Setting up Travis CI for CI."
            cat > .travis.yml <<EOL
language: python
python:
  - "$PYTHON_VERSION"
  - "3.8"
  - "3.9"
  - "3.10"

install:
  - pip install -r requirements.txt
  - pip install pytest $LINTER $FORMATTER

script:
  - $LINTER .
  - pytest
EOL
            ;;
        circleci)
            log "Setting up CircleCI for CI."
            mkdir -p .circleci
            cat > .circleci/config.yml <<EOL
version: 2.1
jobs:
  build:
    docker:
      - image: cimg/python:$PYTHON_VERSION
    steps:
      - checkout
      - run:
          name: Install dependencies
          command: |
            python -m pip install --upgrade pip
            pip install -r requirements.txt
            pip install pytest $LINTER $FORMATTER
      - run:
          name: Lint
          command: $LINTER .
      - run:
          name: Test
          command: pytest
workflows:
  version: 2
  build:
    jobs:
      - build
EOL
            ;;
        *)
            log "Unsupported CI service: $service. Skipping CI setup."
            ;;
    esac

    log "$service CI setup completed."
}

# Function to create requirements.txt or pyproject.toml
create_dependency_files() {
    local build_system="$1"

    if [ "$build_system" = "poetry" ]; then
        log "Using Poetry for dependency management."
    else
        log "Creating requirements.txt."
        touch requirements.txt
    fi
}

# Function to set up GitHub repository via GitHub CLI
create_github_repo() {
    local package="$1"

    if command_exists "gh"; then
        log "Creating GitHub repository: $package"
        gh repo create "$package" --public --source=. --push
        log "GitHub repository '$package' created and remote set."
    else
        log "GitHub CLI 'gh' not found. Skipping repository creation."
    fi
}

# Function to set up code formatter
setup_formatter() {
    local formatter="$1"

    if [ "$formatter" = "black" ]; then
        log "Configuring Black formatter."
        # Additional configuration can be added here if needed
    elif [ "$formatter" = "autopep8" ]; then
        log "Configuring AutoPEP8 formatter."
        # Additional configuration can be added here if needed
    fi
}

# Function to set up linter
setup_linter() {
    local linter="$1"

    if [ "$linter" = "flake8" ]; then
        log "Configuring Flake8 linter."
        cat > .flake8 <<EOL
[flake8]
max-line-length = 88
extend-ignore = E203
EOL
    elif [ "$linter" = "pylint" ]; then
        log "Configuring Pylint linter."
        cat > .pylintrc <<EOL
[MASTER]
ignore=venv
EOL
    fi
}

# Function to parse command-line arguments
parse_args() {
    if [ $# -lt 1 ]; then
        usage
    fi

    PACKAGE_NAME=""
    BUILD_SYSTEM="setuptools"
    LAYOUT="src"
    TEST_FRAMEWORK="unittest"
    CI_SERVICE="github"
    FORMATTER="none"
    LINTER="none"
    ENV_TOOL="venv"
    PYTHON_VERSION="3"
    LICENSE_TYPE="MIT"
    CREATE_REPO=false
    SETUP_DOCS=false
    REMOTE_URL=""

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --git)
                INIT_GIT=true
                shift
                ;;
            --remote)
                if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                    REMOTE_URL="$2"
                    shift 2
                else
                    log "Error: --remote requires an argument."
                    usage
                fi
                ;;
            --create-repo)
                CREATE_REPO=true
                shift
                ;;
            --license)
                if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                    LICENSE_TYPE="$2"
                    shift 2
                else
                    log "Error: --license requires an argument."
                    usage
                fi
                ;;
            --build-system)
                if [[ "$2" == "setuptools" || "$2" == "poetry" ]]; then
                    BUILD_SYSTEM="$2"
                else
                    log "Unsupported build system: $2. Supported: setuptools, poetry."
                    exit 1
                fi
                shift 2
                ;;
            --layout)
                if [[ "$2" == "src" || "$2" == "direct" ]]; then
                    LAYOUT="$2"
                else
                    log "Unsupported layout: $2. Supported: src, direct."
                    exit 1
                fi
                shift 2
                ;;
            --tests)
                if [[ "$2" == "unittest" || "$2" == "pytest" ]]; then
                    TEST_FRAMEWORK="$2"
                else
                    log "Unsupported testing framework: $2. Supported: unittest, pytest."
                    exit 1
                fi
                shift 2
                ;;
            --ci)
                if [[ "$2" == "github" || "$2" == "travis" || "$2" == "circleci" ]]; then
                    CI_SERVICE="$2"
                else
                    log "Unsupported CI service: $2. Supported: github, travis, circleci."
                    exit 1
                fi
                shift 2
                ;;
            --format)
                if [[ "$2" == "black" || "$2" == "autopep8" || "$2" == "none" ]]; then
                    FORMATTER="$2"
                else
                    log "Unsupported formatter: $2. Supported: black, autopep8, none."
                    exit 1
                fi
                shift 2
                ;;
            --lint)
                if [[ "$2" == "flake8" || "$2" == "pylint" || "$2" == "none" ]]; then
                    LINTER="$2"
                else
                    log "Unsupported linter: $2. Supported: flake8, pylint, none."
                    exit 1
                fi
                shift 2
                ;;
            --docs)
                SETUP_DOCS=true
                shift
                ;;
            --env)
                if [[ "$2" == "venv" || "$2" == "virtualenv" || "$2" == "poetry" ]]; then
                    ENV_TOOL="$2"
                else
                    log "Unsupported environment tool: $2. Supported: venv, virtualenv, poetry."
                    exit 1
                fi
                shift 2
                ;;
            --python)
                if [[ "$2" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    PYTHON_VERSION="$2"
                else
                    log "Invalid Python version: $2."
                    exit 1
                fi
                shift 2
                ;;
            --help)
                usage
                ;;
            *)
                if [ -z "$PACKAGE_NAME" ]; then
                    PACKAGE_NAME="$1"
                    shift
                else
                    log "Unknown option: $1"
                    usage
                fi
                ;;
        esac
    done

    # Validate package name
    if [[ ! "$PACKAGE_NAME" =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
        log "Invalid package name: $PACKAGE_NAME"
        log "Package name must start with a letter or underscore and contain only letters, numbers, and underscores."
        exit 1
    fi
}

# Function to prompt user for information if not provided
prompt_user_info() {
    if [ -z "$AUTHOR_NAME" ]; then
        read -p "Enter author name: " AUTHOR_NAME
    fi
    if [ -z "$AUTHOR_EMAIL" ]; then
        read -p "Enter author email: " AUTHOR_EMAIL
    fi
    if [ -z "$DESCRIPTION" ]; then
        read -p "Enter project description: " DESCRIPTION
    fi
    if [ -z "$GITHUB_URL" ]; then
        read -p "Enter GitHub URL (optional): " GITHUB_URL
        GITHUB_URL=${GITHUB_URL:-"https://github.com/yourusername/$PACKAGE_NAME"}
    fi
}

# =============================================================================
# Main Script Execution
# =============================================================================

# Initialize log file
echo "=== Python Package Creation Log ===" > "$LOG_FILE"

# Parse command-line arguments
parse_args "$@"

# Prompt for user information
prompt_user_info

# Determine package directory based on layout
if [ "$LAYOUT" = "src" ]; then
    PACKAGES_DIR="src"
else
    PACKAGES_DIR="."
fi

# Check for necessary dependencies
check_dependencies

# Create project directories
create_directories "$PACKAGE_NAME" "$LAYOUT"

# Navigate into project directory
cd "$PACKAGE_NAME"

# Create build system files
create_build_files "$PACKAGE_NAME" "$BUILD_SYSTEM"

# Create README.md
create_readme "$PACKAGE_NAME"

# Create .gitignore
create_gitignore

# Create dependency files
create_dependency_files "$BUILD_SYSTEM"

# Fetch and create LICENSE file
fetch_license "$LICENSE_TYPE" "$AUTHOR_NAME"

# Initialize Git repository if requested
if [ "$INIT_GIT" = true ] || [ "$CREATE_REPO" = true ]; then
    init_git
fi

# Set up Git remote if provided
if [ -n "$REMOTE_URL" ]; then
    log "Setting Git remote to $REMOTE_URL"
    git remote add origin "$REMOTE_URL"
fi

# Create virtual environment
create_virtualenv "$ENV_TOOL" "$PYTHON_VERSION"

# Activate virtual environment
activate_virtualenv "$ENV_TOOL"

# Determine install and test commands
if [ "$BUILD_SYSTEM" = "poetry" ]; then
    INSTALL_COMMAND="poetry install"
    TEST_RUN_COMMAND="poetry run pytest"
else
    INSTALL_COMMAND="pip install -e ."
    if [ "$TEST_FRAMEWORK" = "pytest" ]; then
        TEST_RUN_COMMAND="pytest"
    else
        TEST_RUN_COMMAND="python -m unittest discover"
    fi
fi

# Install dependencies
install_dependencies "$ENV_TOOL" "$BUILD_SYSTEM"

# Set up formatter and linter
if [ "$FORMATTER" != "none" ] || [ "$LINTER" != "none" ]; then
    setup_precommit
    setup_formatter "$FORMATTER"
    setup_linter "$LINTER"
fi

# Set up Sphinx documentation if requested
if [ "$SETUP_DOCS" = true ]; then
    setup_sphinx
fi

# Set up Continuous Integration
if [ "$CI_SERVICE" != "none" ]; then
    setup_ci "$CI_SERVICE"
fi

# Set up GitHub repository if requested
if [ "$CREATE_REPO" = true ]; then
    create_github_repo "$PACKAGE_NAME"
fi

# Final Instructions
log "======================================"
log "Python package '$PACKAGE_NAME' has been created successfully!"
log "To get started:"
log "1. Navigate to the project directory:"
log "   cd $PACKAGE_NAME"
if [ "$INIT_GIT" = true ] || [ "$CREATE_REPO" = true ]; then
    log "2. Set up the remote repository (if not already set):"
    log "   git remote add origin <your-repo-url>"
fi
log "3. Activate the virtual environment:"
if [ "$ENV_TOOL" = "poetry" ]; then
    log "   poetry shell"
else
    log "   source venv/bin/activate"
fi
if [ "$TEST_FRAMEWORK" = "pytest" ]; then
    log "4. Install pytest for testing:"
    log "   pip install pytest"
fi
log "5. Start coding!"
log "Happy coding!"
log "======================================"

# End of Script
