# Generating SAST v15 report with C/C++test Standard

To report Static Analysis results using SAST v15 format:

1. Copy the [`sast.xsl`](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/sast/cpptest-standard-sast15/sast.xsl) file into the C/C++test installation root folder (`<CPPTEST_INSTALL_DIR>`).
2. Modify your GitLab pipeline to use the new `sast.xsl` report transformer - see `# MODIFICATION` lines below:
```yaml
    ...
    # Configures advanced reporting options and SCM integration.
    - echo "Configuring reporting options..."  

    # ### sast-15-begin ###
    # MODIFICATION: use 'custom' instead of 'sast-gitlab':  
    - echo "report.format=xml,html,custom" > report.properties
    # MODIFICATION: configure file extension for the SAST report:  
    - echo "report.custom.extension=sast" >> report.properties
    # MODIFICATION: specify location of the SAST report transformer:  
    - echo "report.custom.xsl.file=<CPPTEST_INSTALL_DIR>/sast.xsl" >> report.properties
    # ### sast-15-end ###
    
    - echo "report.scontrol=min" >> report.properties
    - echo "scontrol.rep.type=git" >> report.properties
    - echo "scontrol.rep.git.url=$CI_PROJECT_URL" >> report.properties
    - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR" >> report.properties
    # When running on Windows, be sure to escape backslashes:
    # - echo "scontrol.rep.git.workspace=$CI_PROJECT_DIR".Replace("\", "\\") >> report.properties
    - echo "scontrol.rep.git.branch=$CI_COMMIT_BRANCH" >> report.properties
    ...
```
3. Run your GitLab pipeline.
