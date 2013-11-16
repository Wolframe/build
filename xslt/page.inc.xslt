<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- debug only: find unmapped XML, disable in production
     TODO: react to page/@debug flag or similar
  -->
<!--
<xsl:include href="default.inc.xslt"/>
-->

<xsl:include href="header.inc.xslt"/>
<xsl:include href="footer.inc.xslt"/>

<xsl:template name="page">
  <xsl:param name="base" select="@base"/>
  <xsl:param name="title"/>

  <html>

    <xsl:call-template name="html-header">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    
    <body>

      <xsl:call-template name="header">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:call-template>

	<!-- content -->
	<div class="wrapper row3">
		<div id="container">
		<!-- ########################################################################################## -->
			<div class="three_quarter first">
			<!-- ################################################################################## -->
				<xsl:apply-templates/>
			</div>
		</div>
	</div>

      <xsl:call-template name="footer">
        <xsl:with-param name="base" select="$base"/>
      </xsl:call-template>
    </body>

  </html>

</xsl:template>

</xsl:stylesheet>
