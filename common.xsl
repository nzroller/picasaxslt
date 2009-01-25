<?xml version="1.0" encoding="UTF-8"?>
<!-- 
/**
  * Common date transformations.
  */
-->
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns="http://www.w3.org/1999/xhtml"
                 xmlns:exsl="http://exslt.org/common"
                 xmlns:date="http://exslt.org/dates-and-times"
                 extension-element-prefixes="date exsl"
                 version="1.0"> 

<xsl:template name="dateSpan">
  <xsl:param name="dateTime" select="date:date()" />
  <xsl:param name="showYear" select="false()" />
  <span class="date">
    <xsl:value-of select="date:month-abbreviation($dateTime)" />
    <em><xsl:value-of select="date:day-in-month($dateTime)" /></em>
    <xsl:if test="$showYear">
      <xsl:text> </xsl:text>
      <xsl:value-of select="date:year($dateTime)" />
    </xsl:if>
  </span>
</xsl:template>


<xsl:template name="dateBox">
  <xsl:param name="dateTime" select="date:date()" />
  <xsl:param name="showYear" select="false()" />
  <div class="date">
    <span class="month">
      <xsl:value-of select="date:month-abbreviation($dateTime)" />
    </span>
    <span class="day"><xsl:value-of select="date:day-in-month($dateTime)" /></span>
    <xsl:if test="$showYear">
      <span class="year"><xsl:value-of select="date:year($dateTime)" /></span>
    </xsl:if>
  </div>
</xsl:template>

</xsl:stylesheet>
