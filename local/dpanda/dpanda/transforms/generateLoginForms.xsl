<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dp="http://www.datapower.com/extensions"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="dp str"
                exclude-result-prefixes="dp str">

    <xsl:output method="html" omit-xml-declaration="yes" />

    <xsl:template match="/">
      <html lang="en" xml:lang="en">
        <xsl:choose>
          <xsl:when test="/input/operation = 'login' or /input/operation = 'error'">
            <dp:set-http-response-header name="'Content-Security-Policy'" value='"default-src &apos;self&apos;"'/>
            <dp:set-http-response-header name="'X-Frame-Options'" value="'SAMEORIGIN'"/>  <!-- for ClickJack -->
            <dp:set-http-response-header name="'Frame-Options'" value="'SAMEORIGIN'"/>    <!-- for ClickJack -->
            <dp:set-http-response-header name="'X-XSS-Protection'" value="'1; mode=block'"/>   <!-- XSS Protection -->

            <xsl:variable name="error">
              <xsl:choose>
                <xsl:when test="/input/operation = 'login'">
                  <xsl:value-of select="'false'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="'true'"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:call-template name="login-page">
              <xsl:with-param name="input" select="/" />
              <xsl:with-param name="error" select="$error" />
            </xsl:call-template>
          </xsl:when>

          <xsl:when test="/input/operation = 'logout'">
            <xsl:call-template name="logout-page"/>
          </xsl:when>

          <xsl:otherwise>
            <head>
              <meta http-equiv="Pragma" content="no-cache"/>
              <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
              <meta charset="UTF-8"/>
              <title>Unexpected Error</title>
            </head>
            <body>
              <h1>Unexpected Error</h1>
              <p>An error occurred, please contact the administrator of the site.</p>
            </body>
          </xsl:otherwise>
        </xsl:choose>
      </html>
    </xsl:template>

    <xsl:template name="logout-page">
      <head>
        <meta http-equiv="Pragma" content="no-cache"/>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
        <meta charset="UTF-8"/>
        <title>Logged out</title>
      </head>
      <body>
        <H2>You are now logged out of the Web Application</H2>
        <P>You will be required to log in again before you can access protected pages.</P>
      </body>
    </xsl:template>

    <xsl:template name="login-page">
      <xsl:param name="input" select="/.."/>
      <xsl:param name="error"/>

      <xsl:variable name="formpolicy" select="$input/input/identity/entry[@type='html-forms-auth']/policy"/>

      <xsl:variable name="action">
        <xsl:choose>
          <xsl:when test="starts-with($formpolicy/FormsLoginPolicy/FormProcessingURL, '/')">
            <xsl:value-of select="substring($formpolicy/FormsLoginPolicy/FormProcessingURL, 2)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$formpolicy/FormsLoginPolicy/FormProcessingURL"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <!-- Meta, title, CSS, favicons, etc. -->
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>Login Page</title>
        <!-- Bootstrap -->
        <link href="vendors/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet"/>
        <!-- Font Awesome -->
        <link href="vendors/font-awesome/css/font-awesome.min.css" rel="stylesheet"/>
        <!-- NProgress -->
        <link href="vendors/nprogress/nprogress.css" rel="stylesheet"/>
        <!-- Animate.css -->
        <link href="vendors/animate.css/animate.min.css" rel="stylesheet"/>
        <!-- Custom Theme Style -->
        <link href="css/custom.css" rel="stylesheet"/>
      </head>

      <body class="login">
        <div>
          <div class="login_wrapper">
            <div class="animate form login_form">
              <section class="login_content">
                <form name="LoginForm" method="post">
                  <xsl:attribute name="action"><xsl:value-of select="$action"/></xsl:attribute>
                  <h1>Login Form</h1>
                  <div>
                    <input type="text" class="form-control" placeholder="Username" required="true">
                      <xsl:attribute name="name"><xsl:value-of select="$formpolicy/FormsLoginPolicy/UsernameField"/></xsl:attribute>
                    </input>
                  </div>
                  <div>
                    <input type="password" class="form-control" placeholder="Password" required="true">
                      <xsl:attribute name="name"><xsl:value-of select="$formpolicy/FormsLoginPolicy/PasswordField"/></xsl:attribute>
                    </input>
                  </div>
                  <div class="error-login">
                    <xsl:if test="$error='true'">
                      * Wrong Username or Password. Please try Again.
                      <br/>
                    </xsl:if>
                  </div>
                  <div>
                    <button type="submit" class="btn btn-default submit" name="login" value="Login">Login</button>
                  </div>

                  <input type="hidden" size="1024">
                    <xsl:attribute name="name"><xsl:value-of select="$formpolicy/FormsLoginPolicy/RedirectField"/></xsl:attribute>
                    <xsl:attribute name="value"><xsl:value-of select="$input/input/content/original-uri"/></xsl:attribute>
                  </input>
                </form>
              </section>
            </div>
          </div>
        </div>
      </body>
    </xsl:template>

</xsl:stylesheet>
