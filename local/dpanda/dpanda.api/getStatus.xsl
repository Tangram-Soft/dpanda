<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.datapower.com/extensions"
  extension-element-prefixes="dp">

  <xsl:template match="/">
    <xsl:variable name="requestFileName" select="substring-after(dp:variable('var://service/URI'),'/dpanda/api/status/')"/>
    <xsl:copy-of select="document(concat('local:///dpanda.api/xml.mgmt.requests/status.requests/',$requestFileName,'.xml'))"/>
  </xsl:template>
</xsl:stylesheet>
