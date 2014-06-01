<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:output method="html" version="1.1" encoding="UTF-8" indent="no"/>

  <xsl:include href="page.inc.xslt"/>
  <xsl:include href="images.xslt"/>

  <xsl:template match="/page">
    <xsl:call-template name="page">
      <xsl:with-param name="base" select="/page/@base"/>
      <xsl:with-param name="title" select="'Build Results'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="builds">
    <xsl:variable name="builds" select="."/>
    <xsl:variable name="platforms" select="document('platforms.xml')/platforms"/>
    <xsl:variable name="archs" select="document('archs.xml')/archs"/>
    <xsl:variable name="results" select="document('../docs/index.xml')/builds"/>
    <h2>Build Results <xsl:value-of select="/page/@project"/></h2>
    <table class="matrix">
     <thead>
      <tr>
        <th>Platform</th>
        <th>Arch</th>
        <xsl:for-each select="$builds/build">
          <th>
            <xsl:variable name="revision" select="revision"/>
            <xsl:element name="a">
              <xsl:attribute name="href">
		<xsl:value-of select="/page/@scmBaseUrl"/><xsl:value-of select="substring($results/build/revision[.=$revision]/../git_version,1,10)"/>
              </xsl:attribute>
              <xsl:attribute name="title">
                <xsl:value-of select="substring($results/build/revision[.=$revision]/../git_version,1,10)"/>
              </xsl:attribute>
              <xsl:value-of select="$revision"/>
            </xsl:element>
          </th>
        </xsl:for-each>
      </tr>
     </thead>

      <xsl:for-each select="$platforms/platform">
        <xsl:variable name="platform" select="."/>
        <xsl:for-each select="$archs/arch">
          <xsl:variable name="arch" select="."/>

          <xsl:variable name="nof_builds" select="count($builds/build/results/result[arch=$arch and platform=$platform]/status)"/>
          <xsl:if test="$nof_builds &gt; 0">
          <tr>
            <th>
            <xsl:call-template name="image">
              <xsl:with-param name="src" select="$platform"/>
            </xsl:call-template>
            &#160;
            <xsl:value-of select="$platform"/>
            </th>
            <th>
              <xsl:value-of select="."/>
            </th>
            <xsl:for-each select="$builds/build">
              <xsl:variable name="revision" select="revision"/>
              <xsl:variable name="orig_status" select="$results/build/revision[.=$revision]/../results/result[arch=$arch and platform=$platform]/status"/>
              <xsl:variable name="status">
                <xsl:choose>
                  <xsl:when test="$orig_status='succeeded'">ok</xsl:when>
                  <xsl:when test="$orig_status='succeeded*'">ok</xsl:when>
                  <xsl:when test="$orig_status='failed'">fail</xsl:when>
                  <xsl:when test="$orig_status='failed*'">fail</xsl:when>
                  <xsl:when test="$orig_status='building'">run</xsl:when>
                  <xsl:when test="$orig_status='building*'">run</xsl:when>
                  <xsl:when test="$orig_status='finished*'">run</xsl:when>
                  <xsl:when test="$orig_status='finished'">run</xsl:when>
                  <xsl:when test="$orig_status='unresolvable'">fail</xsl:when>
                  <xsl:when test="$orig_status='disabled'">disa</xsl:when>
                  <xsl:when test="$orig_status='skip'">skip</xsl:when>
                  <xsl:when test="$orig_status='excluded'">skip</xsl:when>
                  <xsl:when test="$orig_status='test_error'">test</xsl:when>
                  <xsl:when test="$orig_status='scheduled'">schd</xsl:when>
                  <xsl:otherwise>??</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:element name="td">
                <xsl:choose>
                  <xsl:when test="$status='ok' or $status='fail' or $status='test'">
                    <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
                    <xsl:element name="a">
                      <xsl:attribute name="href">
                         <xsl:value-of select="revision"/>/<xsl:value-of select="$arch"/>/<xsl:value-of select="$platform"/>/log.xml
                      </xsl:attribute>
                      <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
                      <xsl:value-of select="$status"/>
                    </xsl:element>
                  </xsl:when>
                  <xsl:when test="$status='disa'">
                    <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
                    --
                  </xsl:when>
                  <xsl:when test="$status='skip'">
                    <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
                    n/a
                  </xsl:when>
                  <xsl:when test="$status='schd'">
                    <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
                    schd
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="class">status_run</xsl:attribute>
                    <xsl:value-of select="$status"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:element>
            </xsl:for-each>
            </tr>
            </xsl:if>
          </xsl:for-each>
      </xsl:for-each>
    </table>
  </xsl:template>


</xsl:stylesheet>
