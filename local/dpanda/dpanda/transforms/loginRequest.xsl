<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  xmlns:dp="http://www.datapower.com/extensions"
  xmlns:dpconfig="http://www.datapower.com/param/config"
  exclude-result-prefixes="dp dpconfig"
  extension-element-prefixes="dp">

  <xsl:param name="dpconfig:dpandaApiUrl" />
  <dp:param name="dpconfig:dpandaApiUrl" required="true">
    <display>dPanda getSamlart API URL</display>
    <default>http://dpanda.localhost:1081/dpanda/api/getSamlart</default>
    <description></description>
  </dp:param>

  <xsl:template match="/">
		 <dp:set-variable name="'var://service/routing-url'" value="concat($dpconfig:dpandaApiUrl,'?',substring-after(dp:variable('var://service/URI'),'?'))"/>
	</xsl:template>

</xsl:stylesheet>
