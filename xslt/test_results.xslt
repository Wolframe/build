<?xml version="1.0" encoding="ISO-8859-1" ?>

<!DOCTYPE xsl:stylesheet [
 <!ENTITY nbsp "&#xa0;">
 <!ENTITY copy "&#169;">
]>

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

  <xsl:template match="tests">

    <h2>Test Result&#160;<xsl:value-of select="/page/@project"/>,&#160;rev.&#160;<xsl:value-of select="revision"/>,&#160;<xsl:value-of select="arch"/>,&#160;<xsl:value-of select="platform"/></h2>
    <table>
      <tr>
        <td class="label">Total number of tests:
        </td>
        <td colspan="2">
          <xsl:value-of select="tests_total"/>
        </td>
      </tr>
      <tr>
        <td class="label">Number of failed tests:
        </td>
        <td colspan="2">
          <xsl:value-of select="tests_failed"/>
        </td>
      </tr>

      <xsl:apply-templates select="testsummary"/>
      
    </table>

  </xsl:template>	  
  
  <xsl:template match="testsummary">
	  
    <tr>
      <td class="label">
		<xsl:value-of select="name"/>

        <xsl:element name="a">
          <xsl:attribute name="href">#<xsl:value-of select="name"/>
			  </xsl:attribute>
<!--
          <xsl:attribute name="href">
            <xsl:value-of select="/page/@base"/><xsl:value-of select="../revision"/>/<xsl:value-of select="../arch"/>/<xsl:value-of select="../platform"/>/detail_test_result.xslt/<xsl:value-of select="name"/>.xml
          </xsl:attribute>
-->
          <xsl:attribute name="title">
            details of <xsl:value-of select="name"/>
            </xsl:attribute>
          <xsl:attribute name="onClick">
			  document.getElementById('details_<xsl:value-of select="name"/>').style.display = 'inline'; return false;
	      </xsl:attribute>
          details
        </xsl:element>
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
        </xsl:element>
        <td>
        (<xsl:value-of select="tests_run - tests_failed"/>/<xsl:value-of select="tests_run"/>)
        </td>

        <xsl:variable name="wanted_name" select="name"/>
        <xsl:apply-templates select="/page/tests/testresults/testresult[@name=$wanted_name]"/>
             
	</tr>
  </xsl:template>
    
  <xsl:template match="testresult">
     <xsl:element name="tr">
        <xsl:attribute name="style">display:none</xsl:attribute>
        <xsl:attribute name="id">details_<xsl:value-of select="@name"/></xsl:attribute>
  	    <td colspan="3">
		     <xsl:apply-templates/>
		  </td>
     </xsl:element>
  </xsl:template>
  
  <xsl:template match="testsuites">
     <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="testsuite">
     <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="testcase">
    <xsl:variable name="status">
      <xsl:choose>
      <xsl:when test="count(failure) &gt; 0">fail
      </xsl:when>
      <xsl:otherwise>ok
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
		<xsl:element name="span">
          <xsl:attribute name="id">span_of_details_<xsl:value-of select="../../../@name"/>_<xsl:value-of select="translate(@name,'/','_')"/></xsl:attribute>
          <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
          <xsl:attribute name="onClick">
			  document.getElementById('details_<xsl:value-of select="../../../@name"/>_<xsl:value-of select="translate(@name,'/','_')"/>').style.display = 'inline-block';
			  document.getElementById('span_of_details_<xsl:value-of select="../../../@name"/>_<xsl:value-of select="translate(@name,'/','_')"/>').style.display = 'inline-block';
	      </xsl:attribute>
          <xsl:value-of select="@name"/>
        </xsl:element>
        
    <xsl:element name="div">
        <xsl:attribute name="id">details_<xsl:value-of select="../../../@name"/>_<xsl:value-of select="translate(@name,'/','_')"/></xsl:attribute>
        <xsl:attribute name="style">display:none</xsl:attribute>
        <xsl:value-of select="failure/@message"/>
    </xsl:element>

  </xsl:template>

</xsl:stylesheet>
