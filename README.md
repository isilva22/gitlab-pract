# Parasoft C/C++test Integration for GitLab

This project provides example pipelines that demonstrate how to integrate Parasoft C/C++test with GitLab. The integration enables you to run code analysis with Parasoft C/C++test and review analysis results directly in GitLab.

Parasoft C/C++test uses a comprehensive set of analysis techniques, including pattern-based static analysis, dataflow analysis, metrics, code coverage, unit testing, and more, to help you verify code quality and ensure compliance with industry standards, such as MISRA, AUTOSAR, and CERT.
 - Request [a free trial](https://www.parasoft.com/products/parasoft-c-ctest/try/) to receive access to Parasoft C/C++test's features and capabilities.
 - See the [user guide](https://docs.parasoft.com/display/CPPTEST20231) for information about Parasoft C/C++test's capabilities and usage.

Please visit the [official Parasoft website](http://www.parasoft.com) for more information about Parasoft C/C++test and other Parasoft products.

- [Static Analysis](#static-analysis)
  - [Quick start](#quick-start-sa)
  - [Example Pipelines](#example-pipelines-sa)
  - [Reviewing Analysis Results](#reviewing-analysis-results-sa)
- [Code Coverage](#code-coverage)
  - [Quick start](#quick-start-cc)
  - [Example Pipelines](#example-pipelines-cc)
  - [Reviewing Analysis Results](#reviewing-analysis-results-cc)

## Static Analysis
### <a name="quick-start-sa"></a> Quick start

To analyze your code with Parasoft C/C++test and review analysis results in GitLab, you need to customize your pipeline to include:
* Integration with your C/C++ build to determine the scope of analysis. 
* A job that will:
  - run C/C++test.
  - upload the analysis report in the SAST format.
  - upload the C/C++test analysis reports in other formats (XML, HTML, etc.).

#### Prerequisites

* This extension requires Parasoft C/C++test 2021.2 (or newer) with a valid Parasoft license.
* We recommend that you execute the pipeline on a GitLab runner with the following components installed and configured on the runner:
   - C/C++ build toolchain
   - Parasoft C/C++test 2021.2 (or newer)
   - On Windows, we recommend that you use PowerShell Core 6 or later. If you use Windows PowerShell 5.1, you must ensure the correct file encoding - see the example pipelines for details.

#### Generating SAST v15 reports

Latest GitLab versions may require SAST v15 reports to present Static Analysis violations. C/C++test 2023.1.1 (or newer) will generate SAST v15 reports by default. To enable SAST v15 reports with previous Parasoft C/C++test installations, go to:
* [Generating SAST v15 report with C/C++test Standard](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/xsl/cpptest-standard-sast15)
* [Generating SAST v15 report with C/C++test Professional](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/xsl/cpptest-professional-sast15)

### <a name="example-pipelines-sa"></a> Example Pipelines
The following examples show simple pipelines for Make and CMake-based projects. The examples assume that C/C++test is run on a GitLab runner and the path to the `cpptestcli` executable is available on `$PATH`.

##### Run C/C++test Standard with CMake project
See also the example [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/static/cpptest-standard-cmake/.gitlab-ci.yml) file.

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

##### Run C/C++test Standard with Make project
See also the example [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/static/cpptest-standard-make/.gitlab-ci.yml) file.

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

##### Run C/C++test Professional with Make project
See also the example [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/static/cpptest-professional-make/.gitlab-ci.yml) file.

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

### <a name="reviewing-analysis-results-sa"></a> Reviewing Analysis Results
When the pipeline completes, you can review the violations reported by C/C++test as code vulnerabilities:
* in the *Security* tab of the GitLab pipeline.
* on GitLab's Vulnerability Report.

You can click each violation reported by C/C++test to review the details and navigate to the code that triggered the violation.

### Baselining Static Analysis Results in Merge Requests
In GitLab, when a merge request is created, static analysis results generated for the branch to be merged are compared with the results generated for the integration branch. As a result, only new violations are presented in the merge request view, allowing developers to focus on the relevant problems for their code changes. 

#### Defining a Merge Request Policy
You can define a merge request policy for your integration branch that will block merge requests due to new violations. To configure this:
1. In your GitLab project view, go to **Security & Compliance>Policies**, and select **New policy**.
1. Select the **Scan result policy** type.
1. In the **Policy details** section, define a rule for Static Application Security Testing (select “IF SAST…”). Configure additional options, if needed.


## Code Coverage
### <a name="quick-start-cc"></a> Quick start

To collect code coverage with Parasoft C/C++test Standard and review coverage results in GitLab, you need to:
* Integrate C/C++test with your C/C++ build to enable code coverage instrumentation. See also [Collecting Code Coverage](https://docs.parasoft.com/display/CPPTEST20231/Collecting+Code+Coverage).
* Customize your pipeline to include a job that will:
  - build your project with code coverage instrumentation enabled.
  - execute the instrumented application.
  - generate C/C++test coverage reports.
  - convert C/C++test coverage report to Cobertura format (using Saxon).
  - upload the coverage reports.

#### Prerequisites
* This extension requires Parasoft C/C++test Standard 2021.2 (or newer) with a valid Parasoft license.
* We recommend that you execute the pipeline on a GitLab runner with the following components installed and configured on the runner:
   - C/C++ build toolchain
   - Parasoft C/C++test Standard 2021.2 (or newer)
   - On Windows, we recommend that you use PowerShell Core 6 or later. If you use Windows PowerShell 5.1, you must ensure the correct file encoding - see the example pipelines for details.
* To support Cobertura format, you need the following files to be accessible on a GitLab runner:
  - Saxon-HE, which you can copy from [here](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/xsl/saxon) or download from [Saxonica](https://www.saxonica.com/download/java.xml).
  - [XSLT file](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/xsl/cpptest-standard-cobertura/cobertura.xsl) for transforming C/C++test coverage report to Cobertura report.

### <a name="example-pipelines-cc"></a> Example Pipelines
##### Run code coverage analysis with C/C++test Standard for CMake project
For details on how to configure CMake project for code coverage analysis, see [Collecting Application Coverage for CMake Projects](https://docs.parasoft.com/display/CPPTEST20231/Collecting+Application+Coverage+for+CMake+Projects).  
See also the example [.gitlab-ci.yml](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/pipelines/coverage/cpptest-standard-cmake/.gitlab-ci.yml) file.

```yaml
# This is a basic pipeline to help you get started with C/C++test integration to collect code coverage for a CMake-based project.

# For details on how to configure CMake project for code coverage analysis, see:
# https://docs.parasoft.com/display/CPPTEST20231/Collecting+Application+Coverage+for+CMake+Projects

# Be sure to configure variables below.
variables:
  CMAKE_PROJECT_NAME: "cmake-project-name"
  CMAKE_APP_NAME: "app-executable"
  CPPTEST_INSTALL_DIR: "path/to/cpptest"
  CPPTEST_XSL_DIR: "path/to/xsl"
  CPPTEST_SAXON_DIR: "path/to/saxon"

stages:
  - test

# Runs code coverage analysis with C/C++test.
cpptest-coverage:
  variables:
    CPPTEST_REPORTS_DIR: "build/cpptest-coverage/$CMAKE_PROJECT_NAME/reports"

  stage: test
  
  # See: https://docs.gitlab.com/ee/ci/testing/code_coverage.html#add-test-coverage-results-using-coverage-keyword 
  coverage: '/ lines \(\d+% covered\)/'
  
  script:
    # When running on Windows with PowerShell 5.1, be sure to enforce the default file encoding:
    # - $PSDefaultParameterValues['Out-File:Encoding'] = 'default'

    # Configures your CMake project and enables code coverage analysis.
    # Be sure 'cpptest-coverage.cmake' was included into your CMake project.
    - echo "Configuring project with coverage enabled..."
    - cmake -DCPPTEST_COVERAGE=ON -DCPPTEST_HOME=$CPPTEST_INSTALL_DIR -S . -B build
    
    # Builds your CMake project.
    - echo "Building project..."
    - cmake --build build

    # Runs the instrumented application.
    - echo "Running tests..."
    - build/$CMAKE_APP_NAME

    # Generates the code coverage report into:
    #   build/cpptest-coverage/<CMAKE_PROJECT_NAME>/reports
    - echo "Generating C/C++test reports..."
    - cmake --build build --target cpptest_coverage_report

    # Converts the coverage report to Cobertura format.
    #
    # To use Saxon for report transformation, a Java executable is required. 
    # C/C++test includes Java which can be used for this purpose.
    #
    # When running on Windows, be sure to replace backslashes:
    #   - $CI_PROJECT_DIR = $CI_PROJECT_DIR.Replace("\", "/")
    - echo "Generating Cobertura report..."
    - $CPPTEST_INSTALL_DIR/bin/jre/bin/java -jar "$CPPTEST_SAXON_DIR/saxon-he-12.2.jar" -xsl:"$CPPTEST_XSL_DIR/cobertura.xsl" -s:"$CPPTEST_REPORTS_DIR/coverage.xml" -o:"$CPPTEST_REPORTS_DIR/cobertura.xml" -t pipelineBuildWorkingDirectory=$CI_PROJECT_DIR

  artifacts:
    # Uploads code coverage results in the Cobertura format, so that they are displayed in GitLab.
    reports:
      coverage_report:
        coverage_format: cobertura
        path: $CPPTEST_REPORTS_DIR/cobertura.xml
    # Uploads all report files (.xml, .html) as build artifacts.
    paths:
      - $CPPTEST_REPORTS_DIR/*
```

### <a name="reviewing-analysis-results-cc"></a> Reviewing Analysis Results
When the pipeline triggered by a merge request completes, you can review the code coverage data collected by C/C++test in the file diff view of the GitLab Merge requests.

Please visit the official GitLab website for more information about [Test coverage visualization](https://docs.gitlab.com/ee/ci/testing/test_coverage_visualization.html).

---
## About
C/C++test integration for GitLab - Copyright (C) 2023 Parasoft Corporation
