<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:variable name="images" select="document('images.xml')/images"/>

<xsl:template name="image">
  <xsl:param name="src"/>

  <xsl:element name="img">
    <xsl:attribute name="src"><xsl:value-of select="/page/@base"/>images/<xsl:value-of select="$images/image[src=$src]/url"/></xsl:attribute>
    <xsl:attribute name="alt">
      <xsl:value-of select="$images/image[src=$src]/alt"/> 
    </xsl:attribute>
    <xsl:attribute name="title">
      <xsl:value-of select="$images/image[src=$src]/alt"/> 
    </xsl:attribute>
    <xsl:attribute name="height">20</xsl:attribute>
    <xsl:attribute name="width">20</xsl:attribute>
  </xsl:element>

</xsl:template>

</xsl:stylesheet>
