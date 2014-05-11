<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:output method="html" version="1.1" encoding="UTF-8" indent="no"/>

  <xsl:include href="page.inc.xslt"/>
  <xsl:include href="images.xslt"/>

  <xsl:template match="/page">
    <xsl:call-template name="page">
      <xsl:with-param name="base" select="/page/@base"/>
      <xsl:with-param name="title" select="'Test Result'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="testresults">

    <h2>Test Result&#160;<xsl:value-of select="/page/@project"/>,&#160;rev.&#160;<xsl:value-of select="revision"/>,&#160;<xsl:value-of select="arch"/>,&#160;<xsl:value-of select="platform"/></h2>
    <table>
      <tr>
        <td class="label">Total number of tests:
        </td>
        <td>
          <xsl:value-of select="tests_total"/>
        </td>
      </tr>
      <tr>
        <td class="label">Number of failed tests:
        </td>
        <td>
          <xsl:value-of select="tests_failed"/>
        </td>
      </tr>

      <xsl:apply-templates select="testresult"/>
      
    </table>

  </xsl:template>	  
  
  <xsl:template match="testresult">
	  
    <tr>
      <td class="label">		  
 	    <xsl:value-of select="name"/>
	  </td>

        <xsl:variable name="orig_status" select="status"/>
        <xsl:variable name="status">
          <xsl:choose>
            <xsl:when test="$orig_status='OK'">ok</xsl:when>
            <xsl:when test="$orig_status='ERROR'">fail</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="td">
	      <xsl:attribute name="style">text-align: left</xsl:attribute>
          <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
          <xsl:value-of select="$orig_status"/>
        (<xsl:value-of select="tests_run - tests_failed"/>/<xsl:value-of select="tests_run"/>)
        </xsl:element>
	</tr>
  </xsl:template>

</xsl:stylesheet>
