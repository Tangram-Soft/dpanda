<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.datapower.com/extensions"
  xmlns:dpconfig="http://www.datapower.com/param/config"
  extension-element-prefixes="dp dpconfig">

  <xsl:param name="dpconfig:dpandaApiBackend" />
  <dp:param name="dpconfig:dpandaApiBackend" required="true">
    <display>API Backend</display>
    <default>http://dpanda.localhost:65011</default>
  </dp:param>

  <xsl:template match="/">
    <dp:set-variable name="'var://service/routing-url'" value="concat($dpconfig:dpandaApiBackend,dp:variable('var://service/URI'))"/>
  </xsl:template>
</xsl:stylesheet>
