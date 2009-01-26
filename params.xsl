<?xml version="1.0" encoding="UTF-8"?>
<!-- 
/**
  * Picasa Atom Photo Feed to SmoothGallery Transform 
  */
-->
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:html="http://www.w3.org/1999/xhtml"
                 xmlns="http://www.w3.org/1999/xhtml"
                 xmlns:exsl="http://exslt.org/common"
                 xmlns:str="http://exslt.org/strings"
                 xmlns:xlink="http://www.w3.org/1999/xlink"
                 xmlns:exif="http://schemas.google.com/photos/exif/2007"
                 xmlns:atom="http://www.w3.org/2005/Atom"
                 xmlns:media="http://search.yahoo.com/mrss/"
                 xmlns:gphoto="http://schemas.google.com/photos/2007"
                 exclude-result-prefixes="exsl exif atom media str xsl html gphoto xlink"
                 version="1.0"> 

  <xsl:param name="scheme.photo" select="'http://schemas.google.com/g/2005#kind'" />
  <xsl:param name="term.photo" select="'http://schemas.google.com/photos/2007#photo'" />

  <xsl:param name="gallery.width" select="720" />
  <xsl:param name="full.photo.width" select="1024" />
  <xsl:param name="thumbnail.width" select="160" />

</xsl:stylesheet>
