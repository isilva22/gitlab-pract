<?xml version="1.0"?>

<!-- Remove for custom transformation - start section -->
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon" extension-element-prefixes="saxon" xmlns:sastutil="sastutil">
    <xsl:script language="java" implements-prefix="sastutil" src="java:com.parasoft.ptest.results.api.reports.USast"/>
<!-- end remove section -->

<!-- Uncomment for custom transformation - start section -->
<!-- xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon" extension-element-prefixes="saxon"-->
<!-- end uncomment section -->
    
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" indent="no" media-type="application/json"/>
    
    <xsl:param name="skip_suppressed">true</xsl:param>

    <xsl:variable name="currResultIdStr" saxon:assignable="yes"/>
    <xsl:variable name="illegalChars" select="'\/&quot;&#xD;&#xA;&#x9;'"/>
    <xsl:variable name="illegalCharReplacements" select="'\/&quot;rnt'"/>
    <xsl:variable name="markdownChars" select="'*_{}[]()#+-.!'"/>
    <xsl:variable name="markdownNewLine">&lt;br /&gt;</xsl:variable>
    <xsl:variable name="nbsp" select="concat('&amp;','nbsp;')" saxon:assignable="yes"/>
    
    <xsl:template match="/ResultsSession">
        <xsl:text>{ "version": "15.0.6"</xsl:text>
        <xsl:text>, "scan": </xsl:text>
        <xsl:call-template name="scan">
            <xsl:with-param name="toolDispName" select="@toolDispName"/>
            <xsl:with-param name="toolId" select="@toolId"/>
            <xsl:with-param name="toolVer" select="@toolVer"/>
            <xsl:with-param name="startTime" select="@time"/>
            <xsl:with-param name="endTime" select="@endTime"/>
        </xsl:call-template>
        <!-- static violations list -->
        <xsl:text>, "vulnerabilities": [</xsl:text>
            <xsl:call-template name="vulnerabilities">
                <xsl:with-param name="toolDispName" select="@toolDispName"/>
                <xsl:with-param name="toolId" select="@toolId"/>
            </xsl:call-template>
            <!-- static violations list -->
        <xsl:text> ] }</xsl:text>
    </xsl:template>
   
    <xsl:template name="vulnerabilities">
        <xsl:param name="toolDispName"/>
        <xsl:param name="toolId"/>

<!-- Remove for custom transformation - start section -->
        <xsl:call-template name="init_cache"/>
<!-- end remove section -->
        <xsl:variable name="firstResult" saxon:assignable="yes">true</xsl:variable>
        <xsl:for-each select="/ResultsSession/CodingStandards/StdViols/*">
            <xsl:if test="string-length(@supp)=0 or @supp!='true' or $skip_suppressed!='true'">
                <xsl:choose>
                    <xsl:when test="$firstResult = 'true'">
                         <saxon:assign name="firstResult">false</saxon:assign>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>, </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="vulnerability">
                    <xsl:with-param name="toolDispName" select="$toolDispName"/>
                    <xsl:with-param name="toolId" select="$toolId"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="scan">
        <xsl:param name="toolDispName"/>
        <xsl:param name="toolId"/>
        <xsl:param name="toolVer"/>
        <xsl:param name="startTime"/>
        <xsl:param name="endTime"/>

        <xsl:text> {</xsl:text>
        <xsl:text> "analyzer": </xsl:text>
        <xsl:call-template name="analyzer">
            <xsl:with-param name="toolId" select="$toolId"/>
            <xsl:with-param name="toolDispName" select="$toolDispName"/>
            <xsl:with-param name="toolVer" select="$toolVer"/>
        </xsl:call-template>
        <xsl:text>, "scanner": </xsl:text>
        <xsl:call-template name="scanner">
            <xsl:with-param name="toolId" select="$toolId"/>
            <xsl:with-param name="toolDispName" select="$toolDispName"/>
            <xsl:with-param name="toolVer" select="$toolVer"/>
        </xsl:call-template>
        <xsl:variable name="startTimeFormatted" saxon:assignable="yes" select="'1970-01-01T00:00:00'"/>
        <xsl:if test="string-length($startTime) > 6">
            <saxon:assign name="startTimeFormatted" select="substring($startTime, 1, string-length($startTime) - 6)"/>
        </xsl:if>
        <xsl:text>, "start_time": "</xsl:text><xsl:value-of select="$startTimeFormatted"/><xsl:text>"</xsl:text>
        <xsl:variable name="endTimeFormatted" saxon:assignable="yes" select="$startTimeFormatted"/>
        <xsl:if test="string-length($endTime) > 6">
            <saxon:assign name="endTimeFormatted" select="substring($endTime, 1, string-length($endTime) - 6)"/>
        </xsl:if>
        <xsl:text>, "end_time": "</xsl:text><xsl:value-of select="$endTimeFormatted"/><xsl:text>"</xsl:text>
        <xsl:text>, "status": "success"</xsl:text>
        <xsl:text>, "type": "sast"</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template name="analyzer">
        <xsl:param name="toolId"/>
        <xsl:param name="toolDispName"/>
        <xsl:param name="toolVer"/>
        <xsl:text> {</xsl:text>
        <xsl:text>"name": "</xsl:text><xsl:value-of select="$toolDispName"/><xsl:text>"</xsl:text>
        <xsl:text>, "id": "</xsl:text><xsl:value-of select="$toolId"/><xsl:text>"</xsl:text>
        <xsl:text>, "version": "</xsl:text><xsl:value-of select="$toolVer"/><xsl:text>"</xsl:text>
        <xsl:text>, "vendor": {</xsl:text><xsl:text>"name": "Parasoft"</xsl:text><xsl:text> }</xsl:text>
        <xsl:text> }</xsl:text>
    </xsl:template>

    <xsl:template name="scanner">
        <xsl:param name="toolId"/>
        <xsl:param name="toolDispName"/>
        <xsl:param name="toolVer"/>

        <xsl:text> {</xsl:text>
        <xsl:text> "name": "</xsl:text><xsl:value-of select="$toolDispName"/><xsl:text>"</xsl:text>
        <xsl:text>, "id": "</xsl:text><xsl:value-of select="$toolId"/><xsl:text>"</xsl:text>
        <xsl:text>, "version": "</xsl:text><xsl:value-of select="$toolVer"/><xsl:text>"</xsl:text>
        <xsl:text>, "vendor": {</xsl:text><xsl:text>"name": "Parasoft"</xsl:text><xsl:text> }</xsl:text>
        <xsl:text> }</xsl:text>
    </xsl:template>

<!-- Remove for custom transformation - start section -->
    <xsl:template name="init_cache">
        <xsl:for-each select="/ResultsSession/Scope/Locations/*">
            <xsl:choose>
                <xsl:when test="@scPath and @repRef">
                    <xsl:variable name="uri" select="sastutil:setUri(@locRef, @scPath)"/>
                    <xsl:variable name="repRef" select="sastutil:setRepRef(@locRef, @repRef)"/>
                    <xsl:if test="@branch">
                        <xsl:variable name="branch" select="sastutil:setBranch(@locRef, @branch)"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="uri" select="sastutil:setUri(@locRef, @uri)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="/ResultsSession/Scope/Repositories/*">
            <xsl:variable name="repUrl" select="sastutil:setRepUrl(@repRef, @url)" />
        </xsl:for-each>
        <xsl:for-each select="/ResultsSession/CodingStandards/Rules/RulesList/*">
            <xsl:variable name="ruleDesc" select="sastutil:setRuleDesc(@id, @desc)" />
            <xsl:variable name="ruleCat" select="sastutil:setRuleCat(@id, @cat)" />
        </xsl:for-each>
    </xsl:template>
<!-- end remove section -->

    <xsl:template name="vulnerability">
        <xsl:param name="toolDispName"/>
        <xsl:param name="toolId"/>
        
        <xsl:text>{ </xsl:text>
        <xsl:variable name="ruleId" select="@rule"/>
        
<!-- Remove for custom transformation - start section -->
        <xsl:variable name="ruleDocUrl" select="sastutil:getRuleDoc(@analyzer,$ruleId)"/>
        <xsl:variable name="ruleDesc" select="sastutil:getRuleDesc($ruleId)"/>
        <xsl:variable name="ruleCat" select="sastutil:getRuleCat($ruleId)"/>
<!-- end remove section -->
        
<!-- Uncomment for custom transformation - start section -->
        <!--xsl:variable name="ruleDocUrl"></xsl:variable>
        <xsl:variable name="ruleDesc" saxon:assignable="yes"></xsl:variable>
        <xsl:variable name="ruleCat" saxon:assignable="yes"></xsl:variable>
        <xsl:for-each select="/ResultsSession/CodingStandards/Rules/RulesList/Rule[@id=($ruleId)]">
            <saxon:assign name="ruleDesc" select="@desc"/>
            <saxon:assign name="ruleCat" select="@cat"/>
        </xsl:for-each-->
<!-- end uncomment section -->
        
        <xsl:variable name="msg">
            <xsl:call-template name="escape_illegal_chars"><xsl:with-param name="text" select="@msg"/></xsl:call-template>
        </xsl:variable>
        <saxon:assign name="currResultIdStr">
            <xsl:call-template name="escape_illegal_chars"><xsl:with-param name="text" select="concat($ruleId,$msg)"/></xsl:call-template>
        </saxon:assign>
        <xsl:text>"description": "</xsl:text>
        <xsl:call-template name="escape_illegal_chars"><xsl:with-param name="text" select="$ruleDesc"/></xsl:call-template>
        <xsl:text>"</xsl:text>
        
        <xsl:text>, </xsl:text> 
        <xsl:call-template name="severity_level">
            <xsl:with-param name="parsoft_severity" select="@sev"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:call-template name="result_physical_location"/>
        
        <xsl:variable name="resultId" saxon:assignable="yes" select="@unbViolId"/>
        <xsl:if test="string-length($resultId) = 0">
<!-- TODO hashcode generation inside of xsl -->
<!-- Remove for custom transformation - start section -->
            <saxon:assign name="resultId" select="sastutil:calculateResultId($currResultIdStr)"/>
<!-- end remove section -->
<!-- Uncomment for custom transformation - start section -->
            <!-- saxon:assign name="resultId" select="$currResultIdStr"/-->
<!-- end uncomment section -->
            
        </xsl:if>
        <xsl:text>, "id": "</xsl:text><xsl:value-of select="$resultId"/><xsl:text>"</xsl:text>
        <xsl:text>, "identifiers": [{</xsl:text>
        <xsl:text>"type": "</xsl:text><xsl:value-of select="$ruleCat"/><xsl:text>"</xsl:text>
        <xsl:text>, "name": "</xsl:text><xsl:value-of select="$ruleId"/><xsl:text>"</xsl:text>
        <xsl:text>, "value": "</xsl:text><xsl:value-of select="$resultId"/><xsl:text>"</xsl:text>
        <xsl:if test="string-length($ruleDocUrl) > 0">
        	<xsl:text>, "url": "</xsl:text><xsl:value-of select="$ruleDocUrl"/><xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:text> }]</xsl:text>

        <xsl:text>, "details": {</xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select="concat('name',$resultId)" /><xsl:text>": {</xsl:text>
        <xsl:text>"name": "</xsl:text><xsl:value-of select="$ruleId" /><xsl:text>"</xsl:text>
        <xsl:text>, "type": "markdown"</xsl:text>
        <xsl:variable name="locationUri">
            <xsl:call-template name="location_uri"><xsl:with-param name="isMainLocation">true</xsl:with-param></xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($locationUri) > 0">
                <xsl:text>, "value": "**[\\[Line </xsl:text><xsl:value-of select="@locStartln" /><xsl:text>\\]](</xsl:text>
                <xsl:value-of select="$locationUri" />
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, "value": "**\\[Line </xsl:text><xsl:value-of select="@locStartln" /><xsl:text>\\]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="escape_markdown_chars"><xsl:with-param name="text" select="@msg" /></xsl:call-template>
        <xsl:text>**</xsl:text>

        <xsl:if test="local-name()='FlowViol'">
            <xsl:call-template name="flow_viol_markdown" />
        </xsl:if>
        <xsl:if test="local-name()='DupViol'">
            <xsl:call-template name="dup_viol_markdown"/>
        </xsl:if>
        <xsl:text>"}</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template name="result_physical_location">
        <xsl:text>"location": { </xsl:text>
        <xsl:call-template name="artifact_location">
        	<xsl:with-param name="startLine" select="@locStartln"/>
        	<xsl:with-param name="startColumn" select="@locStartPos"/>
        	<xsl:with-param name="endLine" select="@locEndLn"/>
        	<xsl:with-param name="endColumn" select="@locEndPos"/>
        </xsl:call-template>
        <xsl:text> }</xsl:text>
    </xsl:template>

    <xsl:template name="artifact_location">
        <xsl:param name="startLine"/>
        <xsl:param name="startColumn"/>
        <xsl:param name="endLine"/>
        <xsl:param name="endColumn"/>

<!-- Remove for custom transformation - start section -->
        <xsl:variable name="uri" saxon:assignable="yes" select="sastutil:getUri(@locRef)"/>
<!-- end remove section -->

<!-- Uncomment for custom transformation - start section -->
        <!--xsl:variable name="uri" saxon:assignable="yes"/>
        <xsl:variable name="locRef" select="@locRef"/>
        <xsl:variable name="locNode" select="/ResultsSession/Scope/Locations/Loc[@locRef=$locRef]"/>
        <xsl:choose>
            <xsl:when test="$locNode/@scPath and $locNode/@repRef">
                <saxon:assign name="uri" select="$locNode/@scPath"/>
            </xsl:when>
            <xsl:otherwise>
                <saxon:assign name="uri" select="$locNode/@uri"/>
            </xsl:otherwise>
        </xsl:choose-->
<!-- end uncomment section -->

        <xsl:text>"file": "</xsl:text>
        <xsl:value-of select="$uri"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="$startLine > 0">
            
            <xsl:text>, "start_line": </xsl:text>
            <xsl:value-of select="$startLine"/>
            
            <xsl:choose>
                <xsl:when test="$endColumn > 0">
                    <xsl:if test="$endLine > $startLine">
                        <xsl:text>, "end_line": </xsl:text>
                        <xsl:value-of select="$endLine"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$endLine - 1 > $startLine">
                        <xsl:text>, "end_line": </xsl:text>
                        <xsl:value-of select="$endLine - 1"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <saxon:assign name="currResultIdStr" select="concat($currResultIdStr, $uri, $startLine, $endLine)"/>

    </xsl:template>
    
    <xsl:template name="escape_illegal_chars">
        <xsl:param name="text"/>
        
        <xsl:call-template name="escape_chars">
            <xsl:with-param name="text" select="$text"/>
            <xsl:with-param name="escapePrefix">\</xsl:with-param>
            <xsl:with-param name="charsToEscape" select="$illegalChars"/>
            <xsl:with-param name="replacements" select="$illegalCharReplacements"/>
            <xsl:with-param name="illegalChar" select="substring($illegalChars,1,1)"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="escape_chars">
        <xsl:param name="text"/>
        <xsl:param name="escapePrefix"/>
        <xsl:param name="charsToEscape"/>
        <xsl:param name="replacements"/>
        <xsl:param name="illegalChar"/>

        <xsl:choose>
            <xsl:when test="$illegalChar = ''">
                <xsl:value-of select="$text"/>
            </xsl:when>
            <xsl:when test="contains($text,$illegalChar)">
                <xsl:call-template name="escape_chars">
                    <xsl:with-param name="text" select="substring-before($text,$illegalChar)"/>
                    <xsl:with-param name="escapePrefix" select="$escapePrefix"/>
                    <xsl:with-param name="charsToEscape" select="$charsToEscape"/>
                    <xsl:with-param name="replacements" select="$replacements"/>
                    <xsl:with-param name="illegalChar" select="substring(substring-after($charsToEscape,$illegalChar),1,1)"/>
                </xsl:call-template>
                <xsl:value-of select="$escapePrefix"/>
                <xsl:value-of select="translate($illegalChar,$charsToEscape,$replacements)"/>
                <xsl:call-template name="escape_chars">
                    <xsl:with-param name="text" select="substring-after($text,$illegalChar)"/>
                    <xsl:with-param name="escapePrefix" select="$escapePrefix"/>
                    <xsl:with-param name="charsToEscape" select="$charsToEscape"/>
                    <xsl:with-param name="replacements" select="$replacements"/>
                    <xsl:with-param name="illegalChar" select="$illegalChar"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="escape_chars">
                    <xsl:with-param name="text" select="$text"/>
                    <xsl:with-param name="escapePrefix" select="$escapePrefix"/>
                    <xsl:with-param name="charsToEscape" select="$charsToEscape"/>
                    <xsl:with-param name="replacements" select="$replacements"/>
                    <xsl:with-param name="illegalChar" select="substring(substring-after($charsToEscape,$illegalChar),1,1)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="severity_level">
        <xsl:param name="parsoft_severity"/>
        
        <xsl:text>"severity": "</xsl:text>
        <xsl:choose>
            <xsl:when test="($parsoft_severity='1')">
                <xsl:text>Critical</xsl:text>
            </xsl:when>
            <xsl:when test="($parsoft_severity='2')">
                <xsl:text>High</xsl:text>
            </xsl:when>
            <xsl:when test="($parsoft_severity='3')">
               <xsl:text>Medium</xsl:text>
            </xsl:when>
            <xsl:when test="($parsoft_severity='4')">
               <xsl:text>Low</xsl:text>
            </xsl:when>
            <xsl:when test="($parsoft_severity='5')">
               <xsl:text>Info</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>Unknown</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"</xsl:text>
    </xsl:template>
<!-- ====================================================== -->
    <xsl:template name="get_last_path_segment">
        <xsl:param name="path" />

        <xsl:variable name="lastSegment1">
            <xsl:call-template name="substring_after_last">
                <xsl:with-param name="haystack" select="$path"/>
                <xsl:with-param name="needle" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lastSegment">
            <xsl:call-template name="substring_after_last">
                <xsl:with-param name="haystack" select="$lastSegment1"/>
                <xsl:with-param name="needle" select="'\'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="escape_illegal_chars"><xsl:with-param name="text" select="$lastSegment"/></xsl:call-template>
    </xsl:template>

    <xsl:template name="substring_after_last">
        <xsl:param name="haystack" />
        <xsl:param name="needle" />

        <xsl:variable name="substring" select="substring-after($haystack,$needle)"/>
        <xsl:choose>
            <xsl:when test="string-length($substring)=0">
                <xsl:value-of select="$haystack" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="substring_after_last">
                    <xsl:with-param name="haystack" select="$substring"/>
                    <xsl:with-param name="needle" select="$needle"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="escape_markdown_chars">
        <xsl:param name="text" />

        <xsl:variable name="text_without_illegal_chars">
            <xsl:call-template name="escape_illegal_chars"><xsl:with-param name="text" select="$text"/></xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="escape_chars">
            <xsl:with-param name="text" select="$text_without_illegal_chars"/>
            <xsl:with-param name="escapePrefix">\\</xsl:with-param>
            <xsl:with-param name="charsToEscape" select="$markdownChars"/>
            <xsl:with-param name="replacements" select="$markdownChars"/>
            <xsl:with-param name="illegalChar" select="substring($markdownChars,1,1)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="location_uri">
        <xsl:param name="isMainLocation"/>

        <xsl:variable name="locRef" select="@locRef"/>

<!-- Remove for custom transformation - start section -->
        <xsl:variable name="uri" select="sastutil:getUri(@locRef)"/>
        <xsl:variable name="repRef" select="sastutil:getRepRef(@locRef)"/>
        <xsl:variable name="branch" select="sastutil:getBranch(@locRef)"/>
        <xsl:variable name="repUrl" select="sastutil:getRepUrl($repRef)"/>
<!-- end remove section -->

<!-- Uncomment for custom transformation - start section -->
        <!--xsl:variable name="uri" saxon:assignable="yes"/>
        <xsl:variable name="repRef" saxon:assignable="yes"/>
        <xsl:variable name="branch" saxon:assignable="yes"/>
        <xsl:variable name="repUrl" saxon:assignable="yes"/>
        
        <xsl:variable name="locNode" select="/ResultsSession/Scope/Locations/Loc[@locRef=$locRef]"/>
        <xsl:choose>
            <xsl:when test="$locNode/@scPath">
                <saxon:assign name="uri" select="$locNode/@scPath"/>
                <saxon:assign name="repRef" select="$locNode/@repRef"/>
                <saxon:assign name="branch" select="$locNode/@branch"/>
            </xsl:when>
            <xsl:otherwise>
                <saxon:assign name="uri" select="$locNode/@uri"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$repRef != ''">
            <xsl:variable name="repNode" select="/ResultsSession/Scope/Repositories/Rep[@repRef=$repRef]"/>
            <saxon:assign name="repUrl" select="$repNode/@url"/>
        </xsl:if-->
<!-- end uncomment section -->

        <xsl:if test="$uri != '' and $repRef != ''">

            <xsl:value-of select="$repUrl" />
            <xsl:text>/-/blob/</xsl:text>
            <xsl:if test="$branch != ''">
                <xsl:value-of select="$branch" /><xsl:text>/</xsl:text>
            </xsl:if>
            <xsl:value-of select="$uri" />

            <xsl:choose>
                <xsl:when test="$isMainLocation = 'true'">
                    <xsl:call-template name="region_params">
                        <xsl:with-param name="startLine" select="@locStartln"/>
                        <xsl:with-param name="endLine" select="@locEndLn"/>
                        <xsl:with-param name="endPos" select="@locEndPos"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="region_params">
                        <xsl:with-param name="startLine" select="@srcRngStartln"/>
                        <xsl:with-param name="endLine" select="@srcRngEndLn"/>
                        <xsl:with-param name="endPos" select="@srcRngEndPos"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="region_params">
        <xsl:param name="startLine"/>
        <xsl:param name="endLine"/>
        <xsl:param name="endPos"/>

        <xsl:if test="$startLine > 0">
            <xsl:text>#L</xsl:text>
            <xsl:value-of select="$startLine" />
            <xsl:if test="$endLine > $startLine">
                <xsl:if test="$endPos = 0 and ($endLine - $startLine) > 1">
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$endLine - 1" />
                </xsl:if>
                <xsl:if test="$endPos != 0">
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$endLine" />
                </xsl:if>
            </xsl:if>
        </xsl:if>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template name="result_markdown_for_gitlab">
        <xsl:variable name="locationUri">
            <xsl:call-template name="location_uri"><xsl:with-param name="isMainLocation">true</xsl:with-param></xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($locationUri) > 0">
                <xsl:text>", "markdown": "**[\\[Line </xsl:text><xsl:value-of select="@locStartln" /><xsl:text>\\]](</xsl:text>
                <xsl:value-of select="$locationUri" />
                <xsl:text>) </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>", "markdown": "**\\[Line </xsl:text><xsl:value-of select="@locStartln" /><xsl:text>\\] </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="escape_markdown_chars"><xsl:with-param name="text" select="@msg" /></xsl:call-template>
        <xsl:text>**</xsl:text>

        <xsl:if test="local-name()='FlowViol'">
            <xsl:value-of select="$markdownNewLine" />
            <xsl:call-template name="flow_viol_markdown" />
        </xsl:if>
        <xsl:if test="local-name()='DupViol'">
            <xsl:value-of select="$markdownNewLine" />
            <xsl:call-template name="dup_viol_markdown"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="flow_viol_markdown">
        <xsl:call-template name="flow_viol_elem_markdown">
            <xsl:with-param name="descriptors" select="./ElDescList/ElDesc"/>
            <xsl:with-param name="extraSpace"></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="flow_viol_elem_markdown">
        <xsl:param name="descriptors"/>
        <xsl:param name="extraSpace"/>

        <xsl:for-each select="$descriptors">
            <xsl:value-of select="$markdownNewLine" />
            <!--             Cause / Point -->
            <xsl:value-of select="$extraSpace"/>
            <xsl:variable name="space" saxon:assignable="yes"/>
            <saxon:assign name="space">
                <xsl:value-of select="$extraSpace"/>
                <xsl:text>&#160;</xsl:text>
                <xsl:text>&#160;</xsl:text>
                <xsl:text>&#160;</xsl:text>
                <xsl:text>&#160;</xsl:text>
                <xsl:text>&#160;</xsl:text>
                <xsl:text>&#160;</xsl:text>
                <xsl:text>&#160;</xsl:text>
                <xsl:text>&#160;</xsl:text>
            </saxon:assign>

            <xsl:for-each select="Anns/Ann">
                <xsl:if test="(@kind = 'cause')">
                    <xsl:text>**</xsl:text><xsl:value-of select="@msg"/><xsl:text>**</xsl:text>
                    <xsl:value-of select="$markdownNewLine" />
                    <xsl:value-of select="$extraSpace"/>
                </xsl:if>
                <xsl:if test="(@kind = 'point')">
                    <xsl:text>**</xsl:text><xsl:value-of select="@msg"/><xsl:text>**</xsl:text>
                    <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                    <xsl:value-of select="$markdownNewLine" />
                    <xsl:value-of select="$extraSpace"/>
                </xsl:if>
            </xsl:for-each>

            <!--             JAVA ? -->
            <xsl:if test="string-length(@ln) > 0">

                <xsl:variable name="locationUri">
                    <xsl:call-template name="location_uri"><xsl:with-param name="isMainLocation">false</xsl:with-param></xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string-length($locationUri) > 0">
                        <xsl:text>[</xsl:text>
                        <xsl:call-template name="get_last_path_segment"><xsl:with-param name="path" select="@srcRngFile"/></xsl:call-template>
                        <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                        <xsl:text>(</xsl:text><xsl:value-of select="@ln"/><xsl:text>)</xsl:text>
                        <xsl:text>](</xsl:text>
                        <xsl:value-of select="$locationUri" />
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="get_last_path_segment"><xsl:with-param name="path" select="@srcRngFile"/></xsl:call-template>
                        <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                        <xsl:text>(</xsl:text><xsl:value-of select="@ln"/><xsl:text>)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
            </xsl:if>

            <!--             code -->
            <xsl:choose>
                <xsl:when test="(@ElType = '.')">
                    <xsl:call-template name="escape_markdown_chars"><xsl:with-param name="text" select="@desc"/></xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="escape_markdown_chars"><xsl:with-param name="text" select="@desc"/></xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="Anns/Ann">
                <xsl:if test="(@kind != 'cause' and @kind !='point')">
                    <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                    <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                    <xsl:text>_\\*\\*\\*</xsl:text>
                    <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                    <xsl:call-template name="escape_markdown_chars"><xsl:with-param name="text" select="@msg"/></xsl:call-template>
                    <xsl:text>_</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <!--             entering to method -->
            <xsl:call-template name="flow_viol_elem_markdown">
                <xsl:with-param name="descriptors" select="ElDescList/ElDesc"/>
                <xsl:with-param name="extraSpace" select="$space"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="dup_viol_markdown">
        <xsl:for-each select="ElDescList/ElDesc[string-length(@supp)=0]">
            <xsl:value-of select="$markdownNewLine" />
            <xsl:choose>
                <xsl:when test="string-length(@ln) > 0">
                    <xsl:text>Review duplicate in:</xsl:text>
                    <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                    <xsl:variable name="locationUri">
                        <xsl:call-template name="location_uri"><xsl:with-param name="isMainLocation">false</xsl:with-param></xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="string-length($locationUri) > 0">
                            <xsl:text>[</xsl:text>
                            <xsl:call-template name="get_last_path_segment"><xsl:with-param name="path" select="@srcRngFile"/></xsl:call-template>
                            <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                            <xsl:text>(</xsl:text><xsl:value-of select="@ln"/><xsl:text>)</xsl:text>
                            <xsl:text>](</xsl:text>
                            <xsl:value-of select="$locationUri" />
                            <xsl:text>)</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="get_last_path_segment"><xsl:with-param name="path" select="@srcRngFile"/></xsl:call-template>
                            <xsl:value-of select="($nbsp)" disable-output-escaping="yes"/>
                            <xsl:text>(</xsl:text><xsl:value-of select="@ln"/><xsl:text>)</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@desc"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
