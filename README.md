# Parasoft C/C++test Integration for GitLab

This project provides example pipelines that demonstrate how to integrate Parasoft C/C++test with GitLab. The integration enables you to run code analysis with Parasoft C/C++test and review analysis results directly in GitLab.

Parasoft C/C++test uses a comprehensive set of analysis techniques, including pattern-based static analysis, dataflow analysis, metrics, code coverage, unit testing, and more, to help you verify code quality and ensure compliance with industry standards, such as MISRA, AUTOSAR, and CERT.
 - Request [a free trial](https://www.parasoft.com/products/parasoft-c-ctest/try/) to receive access to Parasoft C/C++test's features and capabilities.
 - See the [user guide](https://docs.parasoft.com/display/CPPTEST20212) for information about Parasoft C/C++test's capabilities and usage.

Please visit the [official Parasoft website](http://www.parasoft.com) for more information about Parasoft C/C++test and other Parasoft products.

- [Quick start](#quick-start)
- [Example Pipelines](#example-pipelines)
- [Reviewing Analysis Results](#reviewing-analysis-results)

## Quick start

To analyze your code with Parasoft C/C++test and review analysis results in GitLab, you need to customize your pipeline to include:
* Integration with your C/C++ build to determine the scope of analysis. 
* A job that will:
  - run C/C++test.
  - upload the analysis report in the SAST format.
  - upload the C/C++test analysis reports in other formats (XML, HTML, etc.).

### Prerequisites

* This extension requires Parasoft C/C++test 2021.2 (or newer) with a valid Parasoft license.
* We recommend that you execute the pipeline on a GitLab runner with the following components installed and configured on the runner:
   - C/C++ build toolchain
   - Parasoft C/C++test 2021.2 (or newer)
   - On Windows, we recommend that you use PowerShell Core 6 or later. If you use Windows PowerShell 5.1, you must ensure the correct file encoding - see the example pipelines for details.

## Example Pipelines
The following examples show simple pipelines for Make and CMake-based projects. The examples assume that C/C++test is run on a GitLab runner and the path to the `cpptestcli` executable is available on `$PATH`.

#### Run C/C++test Standard with CMake project
See also the example [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/cpptest-standard-cmake/.gitlab-ci.yml) file.

```yaml
# This is a basic pipeline to help you get started with C/C++test integration to analyze a CMake-based project.

stages:
  - build         
  - test

build-cmake:
  stage: build
  script:
    # Configures your CMake project. Be sure the compile_commands.json file is created.
    - echo "Configuring project..."
    - cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -S . -B build
    # Builds your CMake project. This step is optional, as it is not required for code analysis.
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
    # When running on Windows with PowerShell 5.1, be sure to enforce the default file encoding:
    # - $PSDefaultParameterValues['Out-File:Encoding'] = 'default'

    # Configures advanced reporting options and SCM integration.
    - echo "Configuring reporting options..."    
    - echo "report.format=xml,html,sast-gitlab" > report.properties
    - echo "report.scontrol=min" >> report.properties
    - echo "scontrol.rep.type=git" >> report.properties
    - echo "scontrol.rep.git.url=$CI_PROJECT_URL" >> report.properties
    - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR" >> report.properties
    # When running on Windows, be sure to escape backslashes:
    # - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR".Replace("\", "\\") >> report.properties
    - echo "scontrol.rep.git.branch=$CI_COMMIT_BRANCH" >> report.properties

    # Launches C/C++test.
    - echo "Running C/C++test..."
    - cpptestcli -compiler gcc_9-64 -config "builtin://Recommended Rules" -input build/compile_commands.json -module . -settings report.properties
  
  artifacts:
    # Uploads analysis results in the GitLab SAST format, so that they are displayed in GitLab.
    reports:
      sast: reports/report.sast
    # Uploads all report files (.xml, .html, .sast) as build artifacts.
    paths:
      - reports/*
```

#### Run C/C++test Standard with Make project
See also the example [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/cpptest-standard-make/.gitlab-ci.yml) file.

```yaml
# This is a basic pipeline to help you get started with C/C++test integration to analyze a Make-based project.

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
    # When running on Windows with PowerShell 5.1, be sure to enforce the default file encoding:
    # - $PSDefaultParameterValues['Out-File:Encoding'] = 'default'

    # Configures advanced reporting options and SCM integration.
    - echo "Configuring reporting options..."    
    - echo "report.format=xml,html,sast-gitlab" > report.properties
    - echo "report.scontrol=min" >> report.properties
    - echo "scontrol.rep.type=git" >> report.properties
    - echo "scontrol.rep.git.url=$CI_PROJECT_URL" >> report.properties
    - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR" >> report.properties
    # When running on Windows, be sure to escape backslashes:
    # - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR".Replace("\", "\\") >> report.properties
    - echo "scontrol.rep.git.branch=$CI_COMMIT_BRANCH" >> report.properties
    # Launches C/C++test.
    - echo "Running C/C++test..."
    - cpptestcli -compiler gcc_9-64 -config "builtin://Recommended Rules" -input cpptestscan.bdf -module . -settings report.properties
  
  artifacts:
    # Uploads analysis results in the GitLab SAST format, so that they are displayed in GitLab.
    reports:
      sast: reports/report.sast
    # Uploads all report files (.xml, .html, .sast) as build artifacts.
    paths:
      - reports/*
```

#### Run C/C++test Professional with Make project
See also the example [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/cpptest-professional-make/.gitlab-ci.yml) file.

```yaml
# This is a basic pipeline to help you get started with C/C++test Professional integration to analyze a Make-based project.

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
    # When running on Windows with PowerShell 5.1, be sure to enforce the default file encoding:
    # - $PSDefaultParameterValues['Out-File:Encoding'] = 'default'

    # Configures project.
    - echo "Configuring project options..."    
    - echo "bdf.import.compiler.family=gcc_9-64" > project.properties
    - echo "bdf.import.location=." >> project.properties
    # Configures advanced reporting options and SCM integration.
    - echo "Configuring reporting options..."    
    - echo "report.format=sast-gitlab" > report.properties
    - echo "report.scontrol=min" >> report.properties
    - echo "scontrol.rep.type=git" >> report.properties
    - echo "scontrol.rep.git.url=$CI_PROJECT_URL" >> report.properties
    - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR" >> report.properties
    # When running on Windows, be sure to escape backslashes:
    # - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR".Replace("\", "\\") >> report.properties
    - echo "scontrol.rep.git.branch=$CI_COMMIT_BRANCH" >> report.properties
    # Launches C/C++test.
    - echo "Running C/C++test..."
    - cpptestcli -config "builtin://Recommended Rules" -data $CI_BUILDS_DIR/cpptest-workspace-$CI_PIPELINE_ID -bdf cpptestscan.bdf -report reports -localsettings project.properties -localsettings report.properties
  after_script:
    # Removes the workspace folder.
    - rm -rf $CI_BUILDS_DIR/cpptest-workspace-$CI_PIPELINE_ID
  artifacts:
    # Uploads analysis results in the GitLab SAST format, so that they are displayed in GitLab.
    reports:
      sast: reports/report.sast
    # Uploads all report files (.xml, .sast) as build artifacts.
    paths:
      - reports/*
```

## Reviewing Analysis Results
When the pipeline completes, you can review the violations reported by C/C++test as code vulnerabilities:
* in the *Security* tab of the GitLab pipeline.
* on GitLab's Vulnerability Report.

You can click each violation reported by C/C++test to review the details and navigate to the code that triggered the violation.

---
## About
C/C++test integration for GitLab - Copyright (C) 2021 Parasoft Corporation
