<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0"
    xmlns:dp="http://www.datapower.com/extensions"
    xmlns:dpconfig="http://www.datapower.com/param/config" 
    extension-element-prefixes="dp dpconfig"
    xmlns:dpquery="http://www.datapower.com/param/query"
    exclude-result-prefixes="soap">
    
    <xsl:template match="/">

        <dp:set-response-header name="'x-dp-response-code'" value="'301 Moved Temporarily'"/>
        <dp:set-http-response-header name="'Location'" value="'/dpanda/index.html'"/>
        <dp:freeze-headers/>

    </xsl:template>

</xsl:stylesheet>
