<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:dp="http://www.datapower.com/extensions"
    xmlns:aaa="http://www.datapower.com/AAAInfo"
    xmlns:func="http://exslt.org/functions"
    xmlns:dpwebgui="http://www.datapower.com/webgui"
	xmlns:regexp="http://exslt.org/regular-expressions"
    xmlns:dpfunc="http://www.datapower.com/extensions/functions"

    extension-element-prefixes="dp"
    exclude-result-prefixes="dp aaa func regexp">

      <xsl:variable name="squot">
      <xsl:text>'</xsl:text>
    </xsl:variable>

    <xsl:variable name="document-url" select="$request/args/document-url" />

    <xsl:variable name="xml-document"></xsl:variable>
    <xsl:variable name="xml-document-error"></xsl:variable>
    
    <xsl:variable name="namespace-option">uri</xsl:variable>
<!--
    <xsl:template mode="section-content" match="/">
        <div style="text-align: left; padding: 12px 24px;">
            <div class="renderXML">
                <ul>
                    <xsl:choose>
                        <xsl:when test="$xml-document-error = ''">
                            <xsl:apply-templates mode="render" select="$xml-document"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </ul>
            </div>
        </div>
    </xsl:template>-->

    <func:function name="dpfunc:node-step">
        <xsl:param name="node"/>

        <xsl:choose>
            <xsl:when test="$namespace-option = 'local'"> <!-- regardless of whether or not namespace-uri($node) != '' -->
                <func:result select="concat('/*[local-name()=', $squot, local-name($node), $squot, ']')"/>
            </xsl:when>
            <xsl:when test="namespace-uri($node) != '' and $namespace-option = 'prefix'">
                <func:result select="concat('/', name($node))"/>
            </xsl:when>
            <xsl:when test="namespace-uri($node) != ''"> <!-- $namespace-option = 'uri' -->
                <func:result select="concat('/*[namespace-uri()=', $squot, namespace-uri($node), $squot,
                                     ' and local-name()=', $squot, local-name($node), $squot, ']')"/>
            </xsl:when>
            <xsl:otherwise>
                <func:result select="concat('/', name($node))"/>
            </xsl:otherwise>
        </xsl:choose>
    </func:function>

    <xsl:template mode="render" match="*">
        <xsl:param name="parent-xpath" select="''"/>
      
        <li>
            <xsl:choose>
                <xsl:when test="count(text()) = 1 and count(*) = 0 and count(comment()) = 0 and count(processing-instruction()) = 0">
                    <xsl:text>&lt;</xsl:text>
                    <a href="javascript:void(0)" onclick='setXPath("{concat($parent-xpath, dpfunc:node-step(.))}");'>
                        <span class="element">
                            <xsl:value-of select="name()"/>
                        </span>
                    </a>
                    
                    <xsl:apply-templates select="@*">                
                        <xsl:with-param name="parent-xpath" select="concat($parent-xpath, dpfunc:node-step(.))"/>
                    </xsl:apply-templates>
                    
                    <xsl:if test=". = /">
                        <xsl:for-each select="namespace::*">
                            <xsl:call-template name="namespace-node"/>
                        </xsl:for-each>
                    </xsl:if>
                    
                    <xsl:call-template name="text-only">
                        <xsl:with-param name="parent-xpath" select="$parent-xpath"/>
                    </xsl:call-template>
                </xsl:when>
                
                <xsl:when test="*|comment()|processing-instruction()">
                    <a href="javascript:void(0)" onclick="switchNode(this);return false" class="parent-element">
                        <img src="/images/minus.gif" alt='' border="0" width="9" height="10" class="switch"/>
                    </a>
                    
                    <xsl:text>&lt;</xsl:text>
                    
                    <a href="javascript:void(0)" onclick='setXPath("{concat($parent-xpath, dpfunc:node-step(.))}");'>
                        <span class="element">
                            <xsl:value-of select="name()"/>
                        </span>
                    </a>
                    
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="parent-xpath" select="concat($parent-xpath, dpfunc:node-step(.))"/>
                    </xsl:apply-templates>
                    
                    <xsl:if test=". = /">
                        <xsl:for-each select="namespace::*">
                            <xsl:call-template name="namespace-node"/>
                        </xsl:for-each>
                    </xsl:if>
                    
                    <xsl:text>></xsl:text>
                    
                    <div>
                        <ul>
                            <xsl:apply-templates mode="render">
                                <xsl:with-param name="parent-xpath">
                                    <xsl:value-of select="concat($parent-xpath, dpfunc:node-step(.))"/>
                                </xsl:with-param>
                            </xsl:apply-templates>
                        </ul>
                        
                        <xsl:text>&lt;/</xsl:text>
                        <span class="element">
                            <xsl:value-of select="name()"/>
                        </span>
                        
                        <xsl:text>></xsl:text>
                    </div>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:text>&lt;</xsl:text>
                    
                    <a href="javascript:void(0)" onclick='setXPath("{concat($parent-xpath, dpfunc:node-step(.))}");'>
                        <span class="element">
                            <xsl:value-of select="name()"/>
                        </span>
                    </a>
                    
                    <!-- <xsl:apply-templates select="@*"/> -->
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="parent-xpath" select="concat($parent-xpath, dpfunc:node-step(.))"/>
                    </xsl:apply-templates>
                    
                    <xsl:if test=". = /">
                        <xsl:for-each select="namespace::*">
                            <xsl:call-template name="namespace-node"/>
                        </xsl:for-each>
                    </xsl:if>
                    
                    <xsl:text> /></xsl:text>
                  
                    <xsl:apply-templates mode="render">
                        <xsl:with-param name="parent-xpath">
                            <xsl:value-of select="concat($parent-xpath, dpfunc:node-step(.))"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </li>
        
    </xsl:template>

    <xsl:template match="@*">
        <xsl:param name="parent-xpath"/>
        
        <xsl:variable name="attr">
            <xsl:choose>
                <xsl:when test="$namespace-option = 'local'"> <!-- regardless of whether or not namespace-uri($node) != '' -->
                    <xsl:value-of select="concat('/@*[local-name()=', $squot, local-name(.), $squot, ']')" />
                </xsl:when>
                <xsl:when test="namespace-uri(.) != '' and $namespace-option = 'prefix'">
                    <xsl:value-of select="concat('/@', name(.))" />
                </xsl:when>
                <xsl:when test="namespace-uri(.) != ''"> <!-- $namespace-option = 'uri' -->
                    <xsl:value-of select="concat('/@*[namespace-uri()=', $squot, namespace-uri(.), $squot,
                                         ' and local-name()=', $squot, local-name(.), $squot, ']')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('/@', name(.))" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="attr-value">
            <xsl:choose>
                <xsl:when test="$namespace-option = 'local'"> <!-- regardless of whether or not namespace-uri($node) != '' -->
                    <xsl:value-of select="concat('[@*[local-name()=', $squot, local-name(.), $squot, ' and normalize-space(.) = ', $squot, normalize-space(.), $squot, ']]')" />
                </xsl:when>
                <xsl:when test="namespace-uri(.) != '' and $namespace-option = 'prefix'">
                    <xsl:value-of select="concat('[@', name(.), '[normalize-space(.) = ', $squot, normalize-space(.), $squot, ']]')" />
                </xsl:when>
                <xsl:when test="namespace-uri(.) != ''"> <!-- $namespace-option = 'uri' -->
                    <xsl:value-of select="concat('[@*[namespace-uri()=', $squot, namespace-uri(.), $squot,
                                         ' and local-name()=', $squot, local-name(.), $squot,' and normalize-space(.) = ', $squot, normalize-space(.), $squot, ']]')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('/@', name(.))" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:text> </xsl:text>
        
        <a href="javascript:void(0)" onclick="setXPath(&#34;{regexp:replace( concat('string(',$parent-xpath, $attr,')'), '\]\[','g',' and ')}&#34;);">
            <span class="attribute-key">
                <xsl:value-of select="name()"/>
            </span>
        </a>
        
        <xsl:text>="</xsl:text> 

        <a href="javascript:void(0)" onclick="setXPath(&#34;{regexp:replace(concat($parent-xpath, $attr-value), '\]\[','g',' and ')}&#34;);">
            <span class="attribute-value">
                <xsl:value-of select="."/>
            </span>
        </a>
        
        <xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="comment()">
        <li>
            <xsl:text>&lt;!-- </xsl:text>
            <span class="comment">
                <xsl:value-of select="."/>
            </span>
            <xsl:text> --></xsl:text>
        </li>
    </xsl:template>

    <xsl:template match="processing-instruction()">
        <li>
            <xsl:text>&lt;?</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>?></xsl:text>
        </li>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:if test="string-length(normalize-space(.))">
            <li class="text">
                <xsl:value-of select="normalize-space(.)"/>
            </li>
        </xsl:if>
    </xsl:template>
  
    <xsl:template name="text-only">
        <xsl:param name="parent-xpath"/>
        
        <xsl:choose>
            <xsl:when test="string-length(normalize-space(.))">
                <xsl:variable name="jstext">
                    <xsl:value-of select="concat('[normalize-space(.) = ', $squot, normalize-space(.), $squot, ']')"/>
                </xsl:variable> 
                
                <xsl:text>></xsl:text>
                
                <span class="text">
                    <a href="javascript:void(0)" onclick='setXPath("{concat($parent-xpath, dpfunc:node-step(.), $jstext)}");'>
                        <xsl:value-of select="normalize-space(.)"/>
                    </a>
                </span>
                
                <xsl:text>&lt;/</xsl:text>
                
                <span class="element">
                    <xsl:value-of select="name()"/>
                </span>
                
                <xsl:text>></xsl:text>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:text> /></xsl:text>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>


    <xsl:template mode="section-content" match="section[@name='show-errors']">
        <xsl:choose>
            <xsl:when test="$xml-document-error != ''">
                <div class="JITstatusError">
                    <xsl:value-of select="dpfunc:get-message('tt.SelectXPath.error.paring.xml')"/><br/>
                    <br/>                       
                    <xsl:value-of select="$xml-document-error"/><br/><br/>
					<xsl:variable name="params">
						<param><xsl:value-of select="$VarValues/value[@name='document-url']"/></param>
					</xsl:variable>
					<xsl:value-of select="dpfunc:get-message('tt.SelectXPath.xml.location', $params)"/>					 
                </div>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>      
    </xsl:template>


    <xsl:template name="namespace-node">    
        <xsl:if test="name() != 'xml'">
            <span class="namespace-key">
                <xsl:text> xmlns:</xsl:text>
                <xsl:value-of select="name()"/>
            </span>

            <xsl:text>="</xsl:text>

            <span class="namespace-value">
                <xsl:value-of select="."/>
            </span>

            <xsl:text>"</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
