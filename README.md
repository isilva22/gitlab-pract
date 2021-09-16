# Parasoft C/C++test integration for GitLab

This integration enables you to run code analysis with Parasoft C/C++test and review analysis results directly in GitLab Pipelines.

Parasoft C/C++test uses a comprehensive set of analysis techniques, including pattern-based static analysis, dataflow analysis, metrics, code coverage, unit testing, and more, to help you verify code quality and ensure compliance with industry standards, such as MISRA, AUTOSAR, and CERT.
 - Request [a free trial](https://www.parasoft.com/products/parasoft-c-ctest/try/) to receive access to Parasoft C/C++test's features and capabilities.
 - See the [user guide](https://docs.parasoft.com/display/CPPTEST20212) for information about Parasoft C/C++test's capabilities and usage.

Please visit the [official Parasoft website](http://www.parasoft.com) for more information about Parasoft C/C++test and other Parasoft products.

- [Quick start](#quick-start)
- [Example Pipelines](#example-pipelines)

## Quick start

To analyze your code with Parasoft C/C++test and review analysis results in Gitlab Pipelines, you need to customize your pipeline to include:
 - Integration with your C/C++ build to determine the scope of analysis. 
 - The job to run C/C++test and upload analysis report in the SAST format.

### Prerequisites

* This extension requires Parasoft C/C++test 2021.2 (or newer) with a valid Parasoft license.
* We recommend that you execute the pipeline on a GitLab runner with the following components installed and configured on the runner:
   - C/C++ build toolchain
   - Parasoft C/C++test 2021.2 (or newer)

## Example Pipelines
The following examples show simple pipelines for Make and CMake-based projects. The examples assume that C/C++test is run on a GitLab runner and the path to the `cpptestcli` executable is available on `$PATH`.

#### Run C/C++test Standard with CMake project
See also: [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/cpptest-standard-cmake/.gitlab-ci.yml)

```yaml
# This is a basic pipeline to help you get started with the C/C++test for a CMake-based project.

stages:
  - build         
  - test

build-cmake:
  stage: build
  script:
    # Configures your CMake project. Be sure the compile_commands.json file is created.
    - echo "Configuring project..."
    - cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -S . -B build
    # Builds your CMake project. (This step is optional, as it is not required for code analysis).
    - echo "Building project..."
    - cmake --build build
  artifacts: 
    # Archives build/compile_commands.json so that it can be used in the 'test' stage.
    paths: 
      - build/compile_commands.json

# Runs code analysis with C/C++test.
cpptest-sast:
  stage: test
  script:
    # Configures advanced reporting options / SCM integration.
    - echo "Configuring reporting options..."    
    - echo "report.format=xml,html,sast-gitlab" > report.properties
    - echo "report.scontrol=min" >> report.properties
    - echo "scontrol.rep.type=git" >> report.properties
    - echo "scontrol.rep.git.url=$CI_PROJECT_URL" >> report.properties
    - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR" >> report.properties
    - echo "scontrol.branch=$CI_COMMIT_BRANCH" >> report.properties

    # Launches C/C++test.
    - echo "Running C/C++test..."
    - cpptestcli -compiler gcc_9-64 -config "builtin://Recommended Rules" -input build/compile_commands.json -module . -settings report.properties
  
  artifacts:
    # Uploads analysis results in the SAST GitLab format, so that they are displayed as GitLab Vulnerability Report.
    reports:
      sast: reports/report.sast
    # Uploads all report files (.xml, .html, .sast) as build artifacts.
    paths:
      - reports/*
```

#### Run C/C++test Standard with Make project
See also: [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/cpptest-standard-make/.gitlab-ci.yml)

```yaml
# This is a basic pipeline to help you get started with the C/C++test for a Make-based project.

stages:
  - build         
  - test

build-make:
  stage: build
  script:
    # Builds your Make project using 'cpptesttrace' to collect input data for code analysis.
    # Be sure 'cpptesttrace' is available on $PATH.
    - echo "Building project..."
    - cpptesttrace make clean all
  artifacts: 
    # Archives cpptestscan.bdf so that it can be used in the 'test' stage.
    paths: 
      - cpptestscan.bdf

# Runs code analysis with C/C++test.
cpptest-sast:
  stage: test
  script:
    # Configures advanced reporting options / SCM integration.
    - echo "Configuring reporting options..."    
    - echo "report.format=xml,html,sast-gitlab" > report.properties
    - echo "report.scontrol=min" >> report.properties
    - echo "scontrol.rep.type=git" >> report.properties
    - echo "scontrol.rep.git.url=$CI_PROJECT_URL" >> report.properties
    - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR" >> report.properties
    - echo "scontrol.branch=$CI_COMMIT_BRANCH" >> report.properties
    # Launches C/C++test.
    - echo "Running C/C++test..."
    - cpptestcli -compiler gcc_9-64 -config "builtin://Recommended Rules" -input cpptestscan.bdf -module . -settings report.properties
  
  artifacts:
    # Uploads analysis results in the SAST GitLab format, so that they are displayed as GitLab Vulnerability Report.
    reports:
      sast: reports/report.sast
    # Uploads all report files (.xml, .html, .sast) as build artifacts.
    paths:
      - reports/*
```

#### Run C/C++test Professional with Make project
See also: [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/cpptest-professional-make/.gitlab-ci.yml)

```yaml
# This is a basic pipeline to help you get started with the C/C++test Professional for a Make-based project.

stages:
  - build         
  - test

build-make:
  stage: build
  script:
    # Builds your Make project using 'cpptesttrace' to collect input data for code analysis.
    # Be sure 'cpptesttrace' is available on $PATH.
    - echo "Building project..."
    - cpptesttrace make clean all
  artifacts: 
    # Archives cpptestscan.bdf so that it can be used in the 'test' stage.
    paths: 
      - cpptestscan.bdf

# Runs code analysis with C/C++test.
cpptest-sast:
  stage: test
  script:
    # Configures project.
    - echo "Configuring project options..."    
    - echo "bdf.import.compiler.family=gcc_9-64" > project.properties
    - echo "bdf.import.location=." >> project.properties
    # Configures advanced reporting options / SCM integration.
    - echo "Configuring reporting options..."    
    - echo "report.format=sast-gitlab" > report.properties
    - echo "report.scontrol=min" >> report.properties
    - echo "scontrol.rep.type=git" >> report.properties
    - echo "scontrol.rep.git.url=$CI_PROJECT_URL" >> report.properties
    - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR" >> report.properties
    - echo "scontrol.branch=$CI_COMMIT_BRANCH" >> report.properties
    # Launches C/C++test.
    - echo "Running C/C++test..."
    - cpptestcli -config "builtin://Recommended Rules" -data $CI_BUILDS_DIR/cpptest-workspace-$CI_PIPELINE_ID -bdf cpptestscan.bdf -report reports -localsettings project.properties -localsettings report.properties
  after_script:
    # Removes workspace folder.
    - rm -rf $CI_BUILDS_DIR/cpptest-workspace-$CI_PIPELINE_ID
  artifacts:
    # Uploads analysis results in the SAST GitLab format, so that they are displayed as GitLab Vulnerability Report.
    reports:
      sast: reports/report.sast
    # Uploads all report files (.xml, .sast) as build artifacts.
    paths:
      - reports/*
```

---
## About
C/C++test integration for Gitlab - Copyright (C) 2021 Parasoft Corporation
