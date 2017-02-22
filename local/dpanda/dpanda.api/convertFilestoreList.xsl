<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:func="http://exslt.org/functions"
  xmlns:str="http://exslt.org/strings"
  xmlns:panda="http://dpanda.com/functions"
  xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx" >

  <func:function name="panda:iterateFilestore">
    <xsl:param name="nodeset"/>

    <xsl:variable name="result">
      <xsl:if test="count($nodeset/directory) > 0">
        <xsl:for-each select="$nodeset/directory">
          <jsonx:object>
            <jsonx:string name="directory">
              <xsl:value-of select="str:tokenize(./@name,'/')[last()]"/>
            </jsonx:string>
            <jsonx:string name="path">
              <xsl:value-of select="./@name"/>
            </jsonx:string>
            <xsl:if test="count(./directory) > 0">
              <jsonx:array name="subdirs">
                <xsl:copy-of select="panda:iterateFilestore(.)"/>
              </jsonx:array>
            </xsl:if>
          </jsonx:object>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <func:result select="$result"/>
  </func:function>

  <xsl:template match="/">
    <xsl:copy>
      <xsl:copy-of select="panda:iterateFilestore(//location)"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
