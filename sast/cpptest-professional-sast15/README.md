# Generating SAST v15 report with C/C++test Professional

_Note: C/C++test 2023.1.1 (or newer) will generate SAST v15 reports by default._

To report Static Analysis results using SAST v15 format:

1. Copy the [`sast.xsl`](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/sast/cpptest-professional-sast15/sast.xsl) file into the `xslt` folder inside C/C++test installation (replacing the existing `sast.xsl` file):  
C/C++test Professional Standalone: `<CPPTEST_INSTALL_DIR>/ide/eclipse/plugins/com.parasoft.xtest.checkers.eclipse.core.cpp_<VERSION>/xslt/`  
C/C++test Professional Plugin for Eclipse: `<ECLIPSE_INSTALL_DIR>/plugins/com.parasoft.xtest.checkers.eclipse.core.cpp_<VERSION</xslt/`  
C/C++test Professional Plugin for Visual Studio: `<CPPTEST_INSTALL_DIR>/plugins/com.parasoft.xtest.checkers.vstudio.core.cpp/xslt/`
2. Run your GitLab pipeline.
