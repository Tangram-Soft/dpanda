<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dp="http://www.datapower.com/extensions"
                xmlns:func="http://exslt.org/functions"
                xmlns:list="http://www.example.com/list"
                xmlns:sd="Tangram-soft.co.il"
                xmlns:xsd="Tangram-soft.שco.il"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="dp">

   <xsl:output method="xml" encoding="utf-8" indent="yes"/>
        
        <!--TODO: 
        *************************************************************************************************
        1. Deal with xsd's with relative url's
        2. Add SOMA username:password as a parameter.
        3.
        *************************************************************************************************
        -->
        <!--=============================================================================================-->

    <xsl:template match="/">
        <xsl:message dp:priority="debug">Main Template</xsl:message>

        <xsl:variable name="webServiceUrl" select="//args/arg[@name='wsdlUrl']/text()"/>
        <xsl:variable name="domainName" select="//args/arg[@name='domain']/text()"/>
        <xsl:variable name="fileName" select="//args/arg[@name='filename']/text()"/>
        <xsl:variable name="folderName" select="//args/arg[@name='target']/text()"/>

        <xsl:message>@@AR Webservice URL: <xsl:value-of select="$webServiceUrl"/></xsl:message>
        <xsl:message>@@AR Domain: <xsl:value-of select="$domainName"/></xsl:message>
        <xsl:message>@@AR Folder: <xsl:value-of select="$folderName"/></xsl:message>
        <xsl:message>@@AR Filename: <xsl:value-of select="$fileName"/></xsl:message>

        <!--Download the WSDL from the network-->
        <xsl:call-template name="downloadFile">
            <xsl:with-param name="webServiceUrl"><xsl:value-of select="$webServiceUrl"/></xsl:with-param>
            <xsl:with-param name="domainName"><xsl:value-of select="$domainName"/></xsl:with-param>
            <xsl:with-param name="folderName"><xsl:value-of select="$folderName"/></xsl:with-param>
            <xsl:with-param name="fileName"><xsl:value-of select="$fileName"/></xsl:with-param>
            <xsl:with-param name="encodedFileContent"><xsl:value-of select="$encodedFileContent"/></xsl:with-param>
        </xsl:call-template>

        <xsl:for-each select="str:tokenize(string(.), ' ')">
            <xsl:message>
                zlolnxzc
                <xsl:value-of select="." />
            </xsl:message>
        </xsl:for-each>

    </xsl:template>


    <!--Uploads a file to Datapower=====================================================================-->
    <xsl:template name="uploadFile">
        <xsl:param name="domainName" />
        <xsl:param name="folderName" />
        <xsl:param name="fileName" />
        <xsl:param name="encodedFileContent" />

        <xsl:message dp:priority="debug">uploadFile Template</xsl:message>
        <xsl:variable name="pwd64" select="dp:encode('dpanda:dpanda','base-64')"/>
        <xsl:variable name="basicAuth" select="concat('Basic ',$pwd64)"/>

        <!-- Creating the Headers for the SOMA request -->
        <xsl:variable name="somaRequestHeaders">
            <header name="Content-Type">application/soap+xml</header>
            <header name="Authorization"><xsl:value-of select="$basicAuth"/></header>
        </xsl:variable>

        <!--ssl-proxy="dpanda.main.server.crypto.profile" -->
        <xsl:message>
        <dp:url-open target="https://dpanda.xml.mgmt:5550/service/mgmt/current" response="xml" http-method="post" http-headers="$somaRequestHeaders" >
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://www.datapower.com/schemas/management">
                <soapenv:Header/>
                  <soapenv:Body>
                    <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
                        <man:set-file name="{$folderName}{$fileName}">
                            <xsl:value-of select="$encodedFileContent"/>
                        </man:set-file>
                    </dp:request>
                </soapenv:Body>
            </soapenv:Envelope>
        </dp:url-open>
        </xsl:message>
    </xsl:template>



    <!--Downloads a file to a variable=================================================================-->
    <xsl:template name="downloadFile">
        <xsl:param name="webServiceUrl"/>
        <xsl:param name="domainName" />
        <xsl:param name="folderName" />
        <xsl:param name="fileName" />

        <xsl:message dp:priority="debug">downloadFile Template</xsl:message>

        <xsl:variable name="Wsdl_File_Response">
            <dp:url-open
                target="{$webServiceUrl}"
                response="responsecode-binary"
                http-method="get">
            </dp:url-open>
        </xsl:variable>

        <xsl:message>@@IM Wsdl_File_Response: <xsl:copy-of select="$Wsdl_File_Response"/></xsl:message>
        <xsl:variable name="encodedFileContent" select="dp:binary-encode($Wsdl_File_Response/result/binary)"/>
        <xsl:message>@@IM encodedFileContent: <xsl:value-of select="$encodedFileContent"/></xsl:message>
        <xsl:variable name="decodedFileContent" select="dp:decode($encodedFileContent,'base-64')"/>
        <xsl:variable name="parsedFileContent" select="dp:parse($decodedFileContent)"/>
        <xsl:message>alon1111: <xsl:copy-of select="$parsedFileContent"/></xsl:message>

        <xsl:variable name="fileNameParam">
            <parameter name="fileName"><xsl:value-of select="$fileName"/></parameter>
        </xsl:variable>

        <!--Context variable for wsdl filename to be used in the changeSchemaLocationAttribute.xsl transform-->
        <dp:set-variable name="'var://context/getWsdlFiles/currentFileName'" value="$fileName"/>

        <!-- TODO: We should pass the fileName as a parameter to the transform function instead of using a context variable -->
        <xsl:variable name="parsedFileContentTransformed">
            <dp:serialize select="dp:transform('local:///dpanda.api/changeSchemaLocationAttribute.xsl',$parsedFileContent)"/>
        </xsl:variable>

        <xsl:variable name="encodedFileContentTransformed" select="dp:encode($parsedFileContentTransformed,'base-64')"/>
        <!-- <xsl:value-of select="$encodedFileContentTransformed"/> -->

        <!--Upload WSDL File to DataPower-->
        <xsl:call-template name="uploadFile">
            <xsl:with-param name="domainName"><xsl:value-of select="$domainName"/></xsl:with-param>
            <xsl:with-param name="folderName"><xsl:value-of select="$folderName"/></xsl:with-param>
            <xsl:with-param name="fileName"><xsl:value-of select="$fileName"/></xsl:with-param>
            <xsl:with-param name="encodedFileContent"><xsl:value-of select="$encodedFileContentTransformed"/></xsl:with-param>
        </xsl:call-template>

        <!--searches for imports, and imports them-->
        <xsl:call-template name="searchImports">
            <xsl:with-param name="source"><xsl:copy-of select="$parsedFileContent"/></xsl:with-param>
            <xsl:with-param name="domainName"><xsl:copy-of select="$domainName"/></xsl:with-param>
            <xsl:with-param name="folderName"><xsl:copy-of select="$folderName"/></xsl:with-param>
            <xsl:with-param name="fileName"><xsl:copy-of select="$fileName"/></xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <!--Recursion looking for imports====================================================================-->
    <xsl:template name="searchImports">
        <xsl:message dp:priority="debug">searchImports Template</xsl:message>
        <xsl:param name="source"/>
        <xsl:param name="domainName"/>
        <xsl:param name="folderName"/>
        <xsl:param name="fileName"/>

        <xsl:for-each select="$source/*[local-name()='definitions']/*[local-name()='types']/*[local-name()='schema']/*[local-name()='import']|$source/*[local-name()='schema']/*[local-name()='include']">
            <xsl:call-template name="downloadFile">
                <xsl:with-param name="webServiceUrl"><xsl:value-of select="./@*[local-name()='schemaLocation']"/></xsl:with-param>
                <xsl:with-param name="domainName"><xsl:value-of select="$domainName"/></xsl:with-param>
                <xsl:with-param name="folderName"><xsl:value-of select="$folderName"/></xsl:with-param>
                <xsl:with-param name="fileName"><xsl:value-of select="concat($fileName,'_xsd.',str:tokenize(./@*[local-name()='schemaLocation'],'=')[last()])"/></xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>

        <!--
        <xsl:call-template name="updateSchemaLocation">
            <xsl:with-param name="source"><xsl:copy-of select="$parsedFileContent"/></xsl:with-param>
            <xsl:with-param name="domainName"><xsl:copy-of select="$domainName"/></xsl:with-param>
            <xsl:with-param name="folderName"><xsl:copy-of select="$folderName"/></xsl:with-param>
            <xsl:with-param name="fileName"><xsl:copy-of select="$fileName"/></xsl:with-param>
        </xsl:call-template>
        -->
    </xsl:template>

    <!--
    <xsl:template name="updateSchemaLocation">
        <xsl:message dp:priority="debug">updateSchemaLocation Template</xsl:message>
        <xsl:param name="source"/>
        <xsl:param name="domainName"/>
        <xsl:param name="folderName"/>
        <xsl:param name="fileName"/>

    </xsl:template>
    -->

    <!--
    1. Add "Include" support beside "Import".V
    2. Add functionality to change the schemaLocation after importing - change the attribute to the 'fileName' attribute + 'schemaName' (non-existent yet).
    3. change template structure to functions.
    -->

</xsl:stylesheet>