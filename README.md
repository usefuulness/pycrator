# PyCrator Python Package Creation Script

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Build](https://github.com/yourusername/ultimate-python-package-script/actions/workflows/main.yml/badge.svg)
![Python Versions](https://img.shields.io/badge/python-3.6%20|%203.7%20|%203.8%20|%203.9%20|%203.10%20|%203.11-blue.svg)

A comprehensive Bash script to automate the creation of Python packages with extensive customization options, including build systems, project layouts, GitHub integration, Continuous Integration (CI) setup, dependency management, and more.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Advanced Options](#advanced-options)
  - [Example Commands](#example-commands)
- [Options](#options)
- [Supported Licenses](#supported-licenses)
- [Project Layouts](#project-layouts)
- [Build Systems](#build-systems)
- [Testing Frameworks](#testing-frameworks)
- [Continuous Integration](#continuous-integration)
- [Code Formatting and Linting](#code-formatting-and-linting)
- [Documentation Setup](#documentation-setup)
- [Virtual Environment Management](#virtual-environment-management)
- [Logging](#logging)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Features

- **Advanced Build Systems**: Choose between `setuptools` and `Poetry` for project configuration.
- **Flexible Project Layouts**: Opt for `src` or `direct` project structures.
- **Automated Repository Management**: Initialize Git repositories and create GitHub repositories via GitHub CLI (`gh`).
- **Enhanced Dependency Management**: Set up pre-commit hooks, code formatters (`black`, `autopep8`), and linters (`flake8`, `pylint`).
- **Documentation Setup**: Integrate Sphinx for professional project documentation.
- **Continuous Integration (CI)**: Configure CI pipelines with GitHub Actions, Travis CI, or CircleCI.
- **Comprehensive License Support**: Choose from multiple licenses with automated license file generation.
- **Robust Error Handling and Logging**: Detailed logging of all actions and errors for easy troubleshooting.
- **Interactive and Non-Interactive Modes**: Fully configurable via command-line flags or guided interactive prompts.
- **Virtual Environment Management**: Select between `venv`, `virtualenv`, or Poetry's built-in environment management.
- **Project Publishing Preparation**: Set up workflows for PyPI publishing and enhanced `README.md` templates.

## Prerequisites

Ensure the following tools are installed on your system:

- **Bash**: Unix shell.
- **Python 3.6+**: Ensure `python3` is available in your PATH.
- **curl**: For fetching license texts.
- **git**: For version control.
- **GitHub CLI (`gh`)** *(optional)*: For GitHub repository creation.

*Note: Some features require additional tools like `poetry` or `pre-commit`. The script will prompt you if these are missing.*

## Installation

1. **Clone the Repository** *(if applicable)*:

   ```bash
   git clone https://github.com/yourusername/ultimate-python-package-script.git
   cd ultimate-python-package-script
   ```

2. **Download the Script**:
   Alternatively, you can download the `create_python_package.sh` script directly.

3. **Make the Script Executable**:

   ```bash
   chmod +x create_python_package.sh
   ```

## Usage

### Basic Usage

Create a new Python package with default settings:

```bash
./create_python_package.sh your_package_name
```

### Advanced Options

The script offers a wide range of options to customize your Python package setup. Below are the available flags and their descriptions.

### Example Commands

1. **Basic Package Creation with Default Settings**:

   ```bash
   ./create_python_package.sh my_package
   ```

2. **Package with Git Initialization and MIT License**:

   ```bash
   ./create_python_package.sh my_package --git --license MIT
   ```

3. **Using Poetry, Src Layout, and Pytest**:

   ```bash
   ./create_python_package.sh my_package --build-system poetry --layout src --tests pytest
   ```

4. **Setting Up GitHub Repository, CI with GitHub Actions, Black Formatter, and Flake8 Linter**:

   ```bash
   ./create_python_package.sh my_package --git --create-repo --license Apache-2.0 --ci github --format black --lint flake8
   ```

5. **Creating a Direct Layout Package with Sphinx Documentation and Virtualenv**:

   ```bash
   ./create_python_package.sh my_package --layout direct --docs --env virtualenv
   ```

## Options

| Flag                      | Description                                                                                     | Example                   |
| ------------------------- | ----------------------------------------------------------------------------------------------- | ------------------------- |
| `--git`                   | Initialize a Git repository                                                                     | `--git`                   |
| `--remote <url>`          | Set remote repository URL                                                                       | `--remote https://github.com/user/repo.git` |
| `--create-repo`           | Create a GitHub repository using GitHub CLI (`gh`)                                              | `--create-repo`           |
| `--license <type>`        | Add a LICENSE file (e.g., MIT, Apache-2.0, GPL-3.0, BSD-3-Clause)                             | `--license MIT`           |
| `--build-system <type>`   | Choose build system: `setuptools` (default) or `poetry`                                         | `--build-system poetry`   |
| `--layout <type>`         | Choose project layout: `src` (default) or `direct`                                              | `--layout direct`         |
| `--tests <framework>`     | Choose testing framework: `unittest` (default) or `pytest`                                     | `--tests pytest`          |
| `--ci <service>`          | Set up Continuous Integration: `github` (default), `travis`, `circleci`                         | `--ci github`             |
| `--format <formatter>`    | Choose code formatter: `black`, `autopep8`, `none` (default)                                  | `--format black`          |
| `--lint <linter>`         | Choose linter: `flake8`, `pylint`, `none` (default)                                            | `--lint flake8`           |
| `--docs`                  | Set up Sphinx documentation                                                                     | `--docs`                  |
| `--env <tool>`            | Choose virtual environment tool: `venv` (default), `virtualenv`, `poetry`                        | `--env virtualenv`        |
| `--python <version>`      | Specify Python version for virtual environment (default: `3`)                                 | `--python 3.8`            |
| `--help`                  | Display help message                                                                            | `--help`                  |

## Supported Licenses

- **MIT**
- **Apache-2.0**
- **GPL-3.0**
- **BSD-3-Clause**

*Additional licenses can be added by extending the script.*

## Project Layouts

- **Src Layout (`--layout src`)**: Organizes package code within a `src/` directory.
  
  ```
  my_package/
  ├── src/
  │   └── my_package/
  │       └── __init__.py
  ├── tests/
  │   └── test_sample.py
  ├── setup.py
  ├── README.md
  └── ...
  ```

- **Direct Layout (`--layout direct`)**: Places package code directly in the project root.
  
  ```
  my_package/
  ├── my_package/
  │   └── __init__.py
  ├── tests/
  │   └── test_sample.py
  ├── setup.py
  ├── README.md
  └── ...
  ```

## Build Systems

- **Setuptools (`--build-system setuptools`)**: Traditional Python build system using `setup.py`.
- **Poetry (`--build-system poetry`)**: Modern dependency and packaging tool with `pyproject.toml`.

## Testing Frameworks

- **Unittest (`--tests unittest`)**: Python's built-in testing framework.
- **Pytest (`--tests pytest`)**: Advanced testing framework with rich features.

## Continuous Integration

Supported CI services:

- **GitHub Actions (`--ci github`)**
- **Travis CI (`--ci travis`)**
- **CircleCI (`--ci circleci`)**

*Configure the desired CI service to automate testing and deployment.*

## Code Formatting and Linting

- **Formatters (`--format`)**:
  - **Black**: Code formatter for consistent styling.
  - **AutoPEP8**: Automatically formats Python code to conform to PEP 8.
  - **None**: Skip formatting setup.

- **Linters (`--lint`)**:
  - **Flake8**: Comprehensive linting tool for style and syntax checks.
  - **Pylint**: Highly configurable linter with extensive checks.
  - **None**: Skip linting setup.

*Pre-commit hooks are configured to enforce code quality.*

## Documentation Setup

- **Sphinx (`--docs`)**: Generate professional documentation with Sphinx.
  
  *Initializes Sphinx in the `docs/` directory with basic configuration.*

## Virtual Environment Management

Choose how to manage your virtual environment:

- **venv (`--env venv`)**: Python's built-in virtual environment tool.
- **virtualenv (`--env virtualenv`)**: Third-party virtual environment tool with additional features.
- **Poetry (`--env poetry`)**: Manages environments automatically when using Poetry as the build system.

## Logging

All actions and errors are logged to `create_py_package.log` within the project directory for easy troubleshooting.

## Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the Repository**

2. **Create a Feature Branch**

   ```bash
   git checkout -b feature/YourFeature
   ```

3. **Commit Your Changes**

   ```bash
   git commit -m "Add your feature"
   ```

4. **Push to the Branch**

   ```bash
   git push origin feature/YourFeature
   ```

5. **Open a Pull Request**

Please ensure your code adheres to the project's coding standards and passes all linting and formatting checks.

## License

This project is licensed under the [MIT License](LICENSE).
