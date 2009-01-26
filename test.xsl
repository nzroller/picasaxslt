<?xml version="1.0" encoding="UTF-8"?>
<!-- 
/**
  * Picasa Atom Photo Feed to SmoothGallery Transform Test
  */
-->
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:html="http://www.w3.org/1999/xhtml"
                 xmlns="http://www.w3.org/1999/xhtml"
                 exclude-result-prefixes="xsl"
                 version="1.0"> 

  <xsl:import href="photos.xsl" />

  <xsl:template match="test">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>The PicasaXSLT Test</title>
        <xsl:call-template name="smooth-gallery-head" />
        <!-- <link href="test.css" /> -->
      </head>
      <body>
        <div id="testing">
          <h1>The PicasaXSLT test</h1>
          <xsl:call-template name="smooth-gallery" />
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
