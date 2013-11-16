<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text"/>                
<xml:strip-space elements="*"/>
  <xsl:template match="*">
    <xsl:variable name="results" select="document('../docs/index.xml')/builds"/>
    <xsl:value-of select="$results/build/revision[.=$revision]/../results/result[arch=$arch and platform=$platform]/status"/>
  </xsl:template>
</xsl:stylesheet>
