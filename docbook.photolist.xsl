<?xml version="1.0" encoding="UTF-8"?>
<!-- 
/**
  * Picasa Atom Photo Feed to Docbook Simplelist Transforms
  * [[Atom Format Specification][http://en.wikipedia.org/wiki/Atom_(standard)]]
  * [[Docbook Simplelist][http://www.docbook.org/tdg5/en/html/simplelist.html]]
  */
-->
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:html="http://www.w3.org/1999/xhtml"
                 xmlns="http://www.w3.org/1999/xhtml"
                 xmlns:d="http://docbook.org/ns/docbook"
                 xmlns:exsl="http://exslt.org/common"
                 xmlns:str="http://exslt.org/strings"
                 xmlns:xlink="http://www.w3.org/1999/xlink"
                 xmlns:exif="http://schemas.google.com/photos/exif/2007"
                 xmlns:atom="http://www.w3.org/2005/Atom"
                 xmlns:media="http://search.yahoo.com/mrss/"
                 xmlns:gphoto="http://schemas.google.com/photos/2007"
                 exclude-result-prefixes="exsl exif atom media str xsl html gphoto xlink"
                 version="1.0"> 

  

  <!-- If max-result = 1, just output the entry, otherwise output a
       list of entries. Process grid of photos. -->
  <xsl:template name="photolist">
    <xsl:param name="columns" select="3" />
    <xsl:param name="max.results" select="9" />
    <!-- process photos for photo grid -->
    <xsl:param name="full.photo.width" select="720" />
    <xsl:param name="thumbnail.width" select="48" />
    <xsl:param name="use.lightbox" select="true()" />

    <!-- a photo feed, or defaults to user's photos feed where photos
         are restricted to three, with various image resizing options.
    -->
    <xsl:param name="feed">
      <xsl:variable name="default.photo.feed">
        <xsl:value-of select="$default.feed.uri" />
        <xsl:value-of select="$default.photo.params" />
      </xsl:variable>

      <xsl:value-of select="document ($default.photo.feed)" />
    </xsl:param>

    <!-- HACK! Using thumbnail.width and full.photo.width to get photos
    with either width or height which are those values -->
    <xsl:variable name="entries" select="$feed/atom:feed/atom:entry[atom:category/@term='http://schemas.google.com/photos/2007#photo']/media:group/media:thumbnail[@width=$thumbnail.width or @width=$full.photo.width or @height=$thumbnail.width or @height=$full.photo.width]/ancestor::atom:entry" />

    <xsl:variable name="photos">
      <xsl:choose>
        <xsl:when test="$max.results &gt; 1 and count($entries) &gt; 1">
          <d:simplelist columns="{$columns}">
            <xsl:apply-templates select="$entries" mode="photolist">
              <xsl:with-param name="full.photo.width" select="$full.photo.width" />
              <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
              <xsl:with-param name="use.lightbox" select="$use.lightbox" />
            </xsl:apply-templates>
          </d:simplelist>
        </xsl:when>
        <xsl:when test="$max.results = 1 and count($entries) = 1">
          <xsl:apply-templates select="$entries" mode="photolist">
            <xsl:with-param name="full.photo.width" select="$full.photo.width" />
            <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
            <xsl:with-param name="use.lightbox" select="$use.lightbox" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            Either an invalid max-results value: <xsl:value-of select="$max.results" />
            or no entries were found:  <xsl:value-of select="count($entries)" />
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:message>PHOTO GRID PHOTOS:<xsl:value-of select="name(exsl:node-set($photos)/*[1])" /></xsl:message>
    <xsl:apply-templates select="exsl:node-set($photos)/*[1]" />
  </xsl:template>


  <!-- If there's more than one entry, output a member of a list,
       otherwise just the entry -->
  <xsl:template match="atom:entry" mode="photolist">
    <xsl:param name="full.photo.width" select="720" />
    <xsl:param name="thumbnail.width" select="48" />
    <xsl:param name="use.lightbox" select="true()" />
    <xsl:variable name="count" select="count(. | preceding-sibling::atom:entry | following-sibling::atom:entry)" />

    <xsl:choose>
      <xsl:when test="$count &gt; 1">
        <d:member>
          <xsl:call-template name="docbook.photo">
            <xsl:with-param name="entry" select="." />
            <xsl:with-param name="use.lightbox" select="$use.lightbox" />
            <xsl:with-param name="full.photo.width" select="$full.photo.width" />
            <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
          </xsl:call-template>
        </d:member>
      </xsl:when>
      <xsl:when test="$count = 1">
        <xsl:call-template name="docbook.photo">
            <xsl:with-param name="entry" select="." />
            <xsl:with-param name="use.lightbox" select="$use.lightbox" />
            <xsl:with-param name="full.photo.width" select="$full.photo.width" />
            <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          Invalid number of entries: <xsl:value-of select="$count" />
        </xsl:message>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <xsl:template name="docbook.photo">
    <xsl:param name="entry" select="." />
    <xsl:param name="use.lightbox" select="true()" />
    <xsl:param name="full.photo.width" select="720" />
    <xsl:param name="thumbnail.width" select="48" />
    
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="normalize-space($entry/atom:summary)!=''">
          <xsl:value-of select="normalize-space($entry/atom:summary)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="contains($entry/atom:title, '.jpg')">
              <xsl:value-of select="substring-before($entry/atom:title, '.jpg')" />
            </xsl:when>
            <xsl:when test="contains($entry/atom:title, '.JPG')">
              <xsl:value-of select="substring-before($entry/atom:title, '.JPG')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$entry/atom:title" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- HACK! Using thumbnail.width and full.photo.width to get photos
    with either width or height which are those values -->
    <xsl:variable name="photo" select="$entry/media:group/media:thumbnail[@width=$full.photo.width or @height=$full.photo.width]" />
    <xsl:variable name="thumbnail" select="$entry/media:group/media:thumbnail[@width=$thumbnail.width or @height=$thumbnail.width]" />

    <xsl:choose>
      <xsl:when test="$use.lightbox">
        <d:link role="lightboxgrid" xlink:href="{$photo/@url}" xlink:title="{$title}">
          <xsl:call-template name="inlinemediaobject">
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="thumbnail" select="$thumbnail" />
          </xsl:call-template>
        </d:link>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="inlinemediaobject">
          <xsl:with-param name="title" select="$title" />
          <xsl:with-param name="thumbnail" select="$thumbnail" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="inlinemediaobject">
    <xsl:param name="title" select="substring-before(media:title[@type='plain'], '.JPG')" />
    <xsl:param name="thumbnail" select="media:thumbnail[@width=48]" />

    <d:inlinemediaobject>
      <d:alt><xsl:value-of select="$title" /></d:alt>
      <d:textobject><d:phrase><xsl:value-of select="$title" /></d:phrase></d:textobject>
      <d:imageobject role="html">
        <d:imagedata width="{$thumbnail/@width}" height="{$thumbnail/@height}" fileref="{$thumbnail/@url}" />
      </d:imageobject>
    </d:inlinemediaobject>
  </xsl:template>

</xsl:stylesheet>
