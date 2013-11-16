<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:output method="html" version="1.1" encoding="UTF-8" indent="no"/>

  <xsl:include href="page.inc.xslt"/>
  <xsl:include href="images.xslt"/>

  <xsl:template match="/page">
    <xsl:call-template name="page">
      <xsl:with-param name="base" select="/page/@base"/>
      <xsl:with-param name="title" select="'Build Result'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="log">
    <h2>Build Result&#160;<xsl:value-of select="revision"/>&#160;<xsl:value-of select="arch"/>&#160;<xsl:value-of select="platform"/></h2>
    <table>
      <tr>
        <td class="label">OSC version:
        </td>
        <td>
          <xsl:value-of select="revision"/>
        </td>
      </tr>
      <tr>
        <td class="label">GIT version:
        </td>
        <td>
          <xsl:element name="a">
            <xsl:attribute name="href">
              https://github.com/mbarbos/Wolframe/tree/<xsl:value-of select="substring(git_version,1,10)"/>
            </xsl:attribute>
            <xsl:value-of select="substring(git_version,1,10)"/>
          </xsl:element>
        </td>
      </tr>
      <tr>
        <td class="label">Architecture:
        </td>
        <td>
          <xsl:value-of select="arch"/>
        </td>
      </tr>
      <tr>
        <td class="label">Platform:
        </td>
        <td>
          <xsl:value-of select="platform"/>&#160;
          <xsl:call-template name="image">
            <xsl:with-param name="src" select="platform"/>
          </xsl:call-template>
        </td>
      </tr>
      <tr>
        <td class="label">OSB build state:
        </td>
        <xsl:variable name="orig_status" select="status"/>
        <xsl:variable name="status">
          <xsl:choose>
            <xsl:when test="$orig_status='succeeded'">ok</xsl:when>
            <xsl:when test="$orig_status='succeeded*'">ok</xsl:when>
            <xsl:when test="$orig_status='failed'">fail</xsl:when>
            <xsl:when test="$orig_status='failed*'">fail</xsl:when>
            <xsl:when test="$orig_status='unresolvable'">fail</xsl:when>
            <xsl:when test="$orig_status='disabled'">-</xsl:when>
            <xsl:otherwise>??</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="td">
          <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
          <xsl:value-of select="$status"/>
        </xsl:element>
      </tr>
      <tr>
        <td class="label">Build logfile:
        </td>
        <td>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="/page/@base"/>docs/<xsl:value-of select="revision"/>/<xsl:value-of select="arch"/>/<xsl:value-of select="platform"/>/log.txt
            </xsl:attribute>
            raw text
          </xsl:element>
        </td>
      </tr>
    </table>
    <xsl:choose>
      <xsl:when test="/page/@browser='lynx2'">
      <pre>
        <xsl:value-of select="tail"/>
      </pre>
      </xsl:when>
      <xsl:otherwise>
        <div class="description">
          <xsl:value-of select="tail"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
