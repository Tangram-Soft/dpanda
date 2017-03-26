<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:mgmt="http://www.datapower.com/schemas/management"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:dpa="http://dpanda.com/functions"
	xmlns:exslt="http://exslt.org/common"
	xmlns:regexp="http://exslt.org/regular-expressions"
	xmlns:func="http://exslt.org/functions"
	exclude-result-prefixes="dp dpconfig "
	extension-element-prefixes="regexp dp dpconfig func dpa exslt">
	version="1.0">

	<xsl:variable name="xmlMgmtInterface" select="'https://dpanda.xml.mgmt:5550/service/mgmt/3.0'"/>

	<func:function name="dpa:setFile">
	<!--this function upload file to local dp storage-->
	  <xsl:param name="setFile_fileName"/>
	  <xsl:param name="setFile_data"/>
	  <!-- <xsl:variable name="setFile_serializedData">
	    <dp:serialize select="$setFile_data" omit-xml-decl="yes"/>
	  </xsl:variable> -->


	  <!-- <xsl:variable name="setFile_encodedData" select="dp:encode($setFile_serializedData,'base-64')"/> -->
	  <xsl:variable name="setFile_setFileResult">
	    <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post">
	      <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
	        <env:Body>
	          <dp:request domain="default" xmlns:dp="http://www.datapower.com/schemas/management">
	            <dp:set-file  name="{$setFile_fileName}">
	              <xsl:value-of select="$setFile_data"/>
	            </dp:set-file>
	          </dp:request>
	        </env:Body>
	      </env:Envelope>
	    </dp:url-open>
	   </xsl:variable>

	   <!--handle set file response-->
	   <xsl:choose>
	     <!--if set file succeeded-->
	     <xsl:when test="contains($setFile_setFileResult//*[name()='dp:result']/text(), 'OK')">
	       <xsl:message dp:type="dpanda-application-backup" dp:priority="debug">set file succeeded</xsl:message>
	       <func:result select="true()"/>
	     </xsl:when>
	     <!--if set file failed-->
	     <xsl:otherwise>
	       <xsl:message dp:type="dpanda-application-backup" dp:priority="error">set file failed</xsl:message>
	       <func:reuslt select="false()"/>
	     </xsl:otherwise>

	   </xsl:choose>

	</func:function>

	<xsl:template match="/">
		<xsl:variable name="fileName" select="dp:variable('var://context/uploadFile/fileName')"/>
		<xsl:variable name="fileData" select="dp:variable('var://context/uploadFile/data')"/>

		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="dpa:setFile($fileName, $fileData)">
					<xsl:value-of select="'succeed'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'failed'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="jsonResponse">
			<xsl:text>{"uploadFileResult":"</xsl:text><xsl:value-of select="$result"/><xsl:text>",</xsl:text>
			<xsl:text>"fileName":"</xsl:text><xsl:value-of select="$fileName"/><xsl:text>"}</xsl:text>
		</xsl:variable>

		<xsl:value-of select="$jsonResponse"/>

	</xsl:template>
</xsl:stylesheet>
