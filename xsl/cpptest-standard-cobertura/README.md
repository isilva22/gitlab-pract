# Generating a Cobertura report with C/C++test Standard

To report Code Coverage results using Cobertura format:

1. Copy the [`cobertura.xsl`](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/xsl/cpptest-standard-cobertura/cobertura.xsl) file into a local directory (`<CPPTEST_XSL_DIR>`).
2. Copy [`Saxon`](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/xsl/saxon) files into a local directory (`<CPPTEST_SAXON_DIR>`).
3. Update your GitLab pipeline to convert `<CPPTEST_REPORTS_DIR>/coverage.xml` report into `<CPPTEST_REPORTS_DIR>/cobertura.xml`:

```yaml
    ...
    # Converts a coverage report to Cobertura format.
    #
    # To use Saxon for report transformation, a Java executable is required. 
    # C/C++test includes Java which can be used for this purpose:
    #   <CPPTEST_INSTALL_DIR>/bin/jre/bin/java
    #
    # When running on Windows, be sure to replace backslashes:
    #   - $CI_PROJECT_DIR = $CI_PROJECT_DIR.Replace("\", "/")
    - echo "Generating Cobertura report..."
    - java -jar "<CPPTEST_SAXON_DIR>/saxon-he-12.2.jar" -xsl:"<CPPTEST_XSL_DIR>/cobertura.xsl" -s:"<CPPTEST_REPORTS_DIR>/coverage.xml" -o:"<CPPTEST_REPORTS_DIR>/cobertura.xml" -t pipelineBuildWorkingDirectory=$CI_PROJECT_DIR

  artifacts:
    # Uploads code coverage results in the Cobertura format, so that they are displayed in GitLab.
    reports:
      coverage_report:
        coverage_format: cobertura
        path: <CPPTEST_REPORTS_DIR>/cobertura.xml
    ...
```
4. Run your GitLab pipeline.
