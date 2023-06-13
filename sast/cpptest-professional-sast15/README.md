# Generating SAST v15 report with C/C++test Professional

To report Static Analysis results using SAST v15 format:

1. Copy [`sast.xsl`](https://gitlab.com/parasoft/cpptest-gitlab/-/blob/master/sast/cpptest-professional-sast15/sast.xsl) file into `xslt` folder inside C/C++test installation (replacing existing `sast.xsl` file):  
C/C++test Professional Standalone: `<CPPTEST_INSTALL_DIR>/ide/eclipse/plugins/com.parasoft.xtest.checkers.eclipse.core.cpp_<VERSION>/xslt/`  
C/C++test Professional Plugin for Eclipse: `<ECLIPSE_INSTALL_DIR>/plugins/com.parasoft.xtest.checkers.eclipse.core.cpp_<VERSION</xslt/`  
C/C++test Professional Plugin for Visual Studio: `<CPPTEST_INSTALL_DIR>/plugins/com.parasoft.xtest.checkers.vstudio.core.cpp/xslt/`
2. Run your GitLab pipeline
