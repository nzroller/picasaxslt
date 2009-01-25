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

  <xsl:import href="common.xsl" />

  <!-- default uri for atom feed -->
  <xsl:param name="default.feed.uri" select="'http://picasaweb.google.com/data/feed/api/user/tester'" />

  <xsl:param name="first.param.separator">
    <xsl:choose>
      <xsl:when test="contains($default.feed.uri, '?')">
        <xsl:text>&amp;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>?</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Picasa doesn't want `&' escaped in the url but XSLT document() handles it -->
  <xsl:param name="default.photo.params">
    <xsl:value-of select="$first.param.separator" />   
    <xsl:text>kind=photo</xsl:text>
    <xsl:text>&amp;start-index=1</xsl:text>
    <xsl:text>&amp;max-results=3</xsl:text>
    <xsl:text>&amp;mgmax=800</xsl:text>
    <xsl:text>&amp;thumbsize=144c,160c,320,400</xsl:text>
  </xsl:param>

  <xsl:param name="default.newsfeed.params">
    <xsl:value-of select="$first.param.separator" />
    <xsl:text>kind=album</xsl:text>
    <xsl:text>&amp;start-index=1</xsl:text>
    <xsl:text>&amp;max-results=3</xsl:text>
    <xsl:text>&amp;imgmax=800</xsl:text>
    <xsl:text>&amp;thumbsize=48c,144c,160c,320,400</xsl:text>
  </xsl:param>


  <xsl:template name="smooth-gallery-head">
    <xsl:if test="count(key('gallery-script-dependancies', 'all')[1]) = 1">
      <!-- more mootools scripts -->
      <xsl:call-template name="local-script">
        <xsl:with-param name="src" select="'scripts/mootools-1.2-more.js'" />
      </xsl:call-template>

      <xsl:call-template name="local-script">
        <xsl:with-param name="src" select="'scripts/compat-mootools-core.js'" />
      </xsl:call-template>

      <xsl:call-template name="local-script">
        <xsl:with-param name="src" select="'scripts/compat-mootools-more.js'" />
      </xsl:call-template>

      <!-- the gallery script -->
      <xsl:call-template name="local-script">
        <xsl:with-param name="src" select="'scripts/jd.gallery.js'" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="smooth-gallery">
    <xsl:param name="gallery.id" select="'myGallery'" />
    <xsl:param name="show.carousel" select="false()" />
    <xsl:param name="embed.links" select="false()" />
    <xsl:param name="show.arrows" select="false()" />
    <xsl:param name="show.infopane" select="false()" />
    <xsl:param name="timed" select="true()" />
    <xsl:param name="fade.duration" select="1000" />
    
    
    <!-- these parameters are passed through to the
         `smooth-gallery-photos' template -->
    <xsl:param name="gallery.feed" />
    <xsl:param name="gallery.width" />
    <xsl:param name="full.photo.width" />
    <xsl:param name="thumbnail.width" />
    <xsl:param name="embed.links" />

    <!-- Script with custom settings to start Smooth Gallery. -->
    <script type="text/javascript" language="JavaScript">
      function startGallery() {
        var myGallery = new gallery($('<xsl:value-of select="$gallery.id" />'), {
          fadeDuration: <xsl:value-of select="$fade.duration" />,
          timed: <xsl:value-of select="$timed" />,
          showCarousel: <xsl:value-of select="$show.carousel" />,
          embedLinks: <xsl:value-of select="$embed.links" />,
          showArrows: <xsl:value-of select="$show.arrows" />,
          showInfopane: <xsl:value-of select="$show.infopane" />,
          elementSelector: "div.entry",
          titleSelector: "h3",
          subtitleSelector: "p",
          linkSelector: "a.open",
          imageSelector: "img.gallery",
          thumbnailSelector: "img.thumbnail"
        });
      }
      window.addEvent('domready', startGallery);
    </script> 

    <div id="{$gallery.id}">
      <!-- now go through the feed of photos -->
      <xsl:call-template name="smooth-gallery-photos">
        <xsl:with-param name="feed" select="document ($gallery.feed)" />
        <xsl:with-param name="gallery.width" select="$gallery.width" />
        <xsl:with-param name="full.photo.width" select="$full.photo.width" />
        <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
        <xsl:with-param name="thumbnails" select="$show.carousel" />
        <xsl:with-param name="embed.links" select="$embed.links" />
      </xsl:call-template>
    </div>
  </xsl:template>


  <!-- process photos for smooth gallery -->
  <xsl:template name="smooth-gallery-photos">
    <xsl:param name="gallery.width" select="720" />
    <xsl:param name="full.photo.width" select="1024" />
    <xsl:param name="thumbnail.width" select="160" />
    <xsl:param name="thumbnails" select="false()" />
    <xsl:param name="embed.links" select="false()" />
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

    <xsl:apply-templates 
        select="$feed/atom:feed/atom:entry[atom:category/@term='http://schemas.google.com/photos/2007#photo']/media:group/media:thumbnail/@width[.=$gallery.width or .=$full.photo.width]/ancestor::atom:entry" 
        mode="smooth-gallery">
      <xsl:with-param name="gallery.width" select="$gallery.width" />
      <xsl:with-param name="full.photo.width" select="$full.photo.width" />
      <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
      <xsl:with-param name="thumbnails" select="$thumbnails" />
      <xsl:with-param name="embed.links" select="$embed.links" />
      <xsl:with-param name="use.lightbox" select="$use.lightbox" />
    </xsl:apply-templates>
  </xsl:template>

  <!-- transform photo entries (not albums or tags for example) -->
  <xsl:template match="atom:entry[atom:category/@term='http://schemas.google.com/photos/2007#photo']"
                mode="smooth-gallery">
    <xsl:param name="gallery.width"  />
    <xsl:param name="full.photo.width"  />
    <xsl:param name="thumbnail.width"  />
    <xsl:param name="thumbnails"  />
    <xsl:param name="embed.links" />
    <xsl:param name="use.lightbox" select="true()" />

    <xsl:variable name="class.value">
      <xsl:text>entry</xsl:text>
      <xsl:if test="not(preceding-sibling::atom:entry[atom:category/@term='http://schemas.google.com/photos/2007#photo'])">
        <xsl:text> first</xsl:text>
      </xsl:if>
      <xsl:if test="not(following-sibling::atom:entry[atom:category/@term='http://schemas.google.com/photos/2007#photo'])">
        <xsl:text> last</xsl:text>
      </xsl:if>
    </xsl:variable>

    <div class="{normalize-space($class.value)}">
      <xsl:apply-templates select="atom:title" mode="smooth-gallery"/>
      <xsl:apply-templates select="atom:summary" mode="smooth-gallery"/>
      <xsl:apply-templates select="media:group" mode="smooth-gallery">
        <xsl:with-param name="gallery.width" select="$gallery.width" />
        <xsl:with-param name="full.photo.width" select="$full.photo.width" />
        <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
        <xsl:with-param name="thumbnails" select="$thumbnails" />
        <xsl:with-param name="embed.links" select="$embed.links" />
        <xsl:with-param name="use.lightbox" select="$use.lightbox" />
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="atom:title[@type='text' and .!='']" mode="smooth-gallery">
    <h3><xsl:value-of select="substring-before(substring-before(., '.jpg'), '.JPG')" /></h3>
  </xsl:template>

  <xsl:template match="atom:summary[@type='text' and .!='']" mode="smooth-gallery">
    <p><xsl:value-of select="." /></p>
  </xsl:template>

  <xsl:template match="media:group" mode="smooth-gallery">
    <xsl:param name="thumbnails" />
    <xsl:param name="thumbnail.width" />
    <xsl:param name="gallery.width" />
    <xsl:param name="embed.links" />
    <xsl:param name="full.photo.width" />
    <xsl:param name="use.lightbox" select="true()" />

    <!--
    <xsl:message>
      group:$thumbnails: <xsl:value-of select="$thumbnails" />
      group:$thumbnail.width: <xsl:value-of select="$thumbnail.width" />
      group:$gallery.width: <xsl:value-of select="$gallery.width" />
      group:$embed.links: <xsl:value-of select="$embed.links" />
      group:$full.photo.width: <xsl:value-of select="$full.photo.width" />
    </xsl:message>
    -->

    <xsl:if test="$thumbnails and $thumbnail.width!=''">
      <xsl:call-template name="media-image">
        <xsl:with-param name="class" select="'thumbnail'" />
        <xsl:with-param name="width" select="$thumbnail.width" />
        <xsl:with-param name="use.lightbox" select="$use.lightbox" />
      </xsl:call-template>
    </xsl:if>

    <xsl:call-template name="media-image">
      <xsl:with-param name="class" select="'gallery'" />
      <xsl:with-param name="width" select="$gallery.width" />
    </xsl:call-template>
    
    <xsl:if test="$embed.links and $full.photo.width!=''">
      <xsl:call-template name="media-link">
        <xsl:with-param name="class" select="'open'" />
        <xsl:with-param name="width" select="$full.photo.width" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- process photos for smooth gallery -->
  <xsl:template name="lightbox-photos">
    <!-- a photo feed, or defaults to user's photos feed where photos
         are restricted to three, with various image resizing options.
    -->
    <xsl:param name="photo.feed">
      
      <xsl:variable name="default.photo.feed">
        <xsl:value-of select="$default.feed.uri" />
        <xsl:value-of select="$default.photo.params" />
      </xsl:variable>
      <xsl:message>
        <xsl:text>Default Photo Feed: </xsl:text>
        <xsl:value-of select="$default.photo.feed" />
      </xsl:message>

      <xsl:value-of select="document ($default.photo.feed)" />
    </xsl:param>

    <xsl:if test="not($photo.feed)">
      <xsl:message terminate="yes">
        <xsl:text>Couldn't retrieve the light box photos feed</xsl:text>
      </xsl:message>
    </xsl:if>

    <xsl:apply-templates select="$photo.feed/atom:feed/atom:entry[atom:category/@term='http://schemas.google.com/photos/2007#photo']/media:group[media:content and media:thumbnail]" 
                         mode="lightbox"/>

  </xsl:template>

  <!-- transform photo entries (not albums or tags for example) -->
  <xsl:template match="media:group" mode="lightbox">
    
    <xsl:apply-templates select="media:thumbnail" mode="lightbox" />
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

  <!-- Process albums for newsfeed. -->
  <xsl:template name="newsfeed">
    <!-- An atom feed, or defaults to user's album feed. -->
    <xsl:param name="news.feed">
      
      <xsl:variable name="default.news.feed">
        <xsl:value-of select="$default.feed.uri" />
        <xsl:value-of select="$default.newsfeed.params" />
      </xsl:variable>

      <xsl:message><xsl:text>Default Newsfeed: </xsl:text>
        <xsl:value-of select="$default.news.feed" />
      </xsl:message>

      <xsl:value-of select="document ($default.news.feed)" />
    </xsl:param>

    <xsl:param name="full.photo.width" />
    <xsl:param name="thumbnail.width" />
    <xsl:param name="use.lightbox" select="true()" />
    <xsl:param name="kind" select="'album'" />

    <ul id="newsfeed" class="{$kind}">
      <!-- entries with a published date, title and summary -->
      <xsl:apply-templates select="$news.feed/atom:feed/atom:entry[atom:published and atom:title[@type='text'] and atom:summary[@type='text']]" 
                           mode="newsfeed">
        <xsl:with-param name="full.photo.width" select="$full.photo.width" />
        <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
        <xsl:with-param name="use.lightbox" select="$use.lightbox" />        
      </xsl:apply-templates>
    </ul>
  </xsl:template>

  <!-- transform photo entries (not albums or tags for example) -->
  <xsl:template match="atom:entry" mode="newsfeed">
    <xsl:param name="full.photo.width" />
    <xsl:param name="thumbnail.width" />
    <xsl:param name="use.lightbox" select="true()" />

    <xsl:variable name="class.value">
      <xsl:text>entry</xsl:text>
      <xsl:if test="not(preceding-sibling::atom:entry)">
        <xsl:text> first</xsl:text>
      </xsl:if>
      <xsl:if test="not(following-sibling::atom:entry)">
        <xsl:text> last</xsl:text>
      </xsl:if>
    </xsl:variable>

    <li class="{normalize-space($class.value)}">
      <xsl:choose>
        <!-- When this is a photo entry, format accordingly. -->
        <xsl:when test="atom:category[@scheme='http://schemas.google.com/g/2005#kind' and @term='http://schemas.google.com/photos/2007#photo']">

          <xsl:variable name="title">
            <xsl:choose>
              <xsl:when test="normalize-space(atom:summary)!=''">
                <xsl:value-of select="normalize-space(atom:summary)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="contains(atom:title, '.jpg')">
                    <xsl:value-of select="substring-before(atom:title, '.jpg')" />
                  </xsl:when>
                  <xsl:when test="contains(atom:title, '.JPG')">
                    <xsl:value-of select="substring-before(atom:title, '.JPG')" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="atom:title" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:apply-templates select="media:group" mode="newsfeed">
            <xsl:with-param name="full.photo.width" select="$full.photo.width" />
            <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
            <xsl:with-param name="use.lightbox" select="$use.lightbox" />
          </xsl:apply-templates>

          <p class="summary"><xsl:value-of select="atom:summary" /></p>

        </xsl:when>
        <xsl:otherwise>
          
          <h4>
            <a href="{atom:link[@rel='alternate' and @type='text/html']/@href}" title="{atom:title}">
              <xsl:value-of select="atom:title" />
            </a>
          </h4>

          <xsl:call-template name="dateSpan">
            <xsl:with-param name="dateTime" select="atom:published" />
          </xsl:call-template>

          <div class="body">
            <xsl:apply-templates select="media:group" mode="newsfeed">
              <xsl:with-param name="full.photo.width" select="$full.photo.width" />
              <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
              <xsl:with-param name="use.lightbox" select="$use.lightbox" />
            </xsl:apply-templates>

            <p class="summary"><xsl:value-of select="atom:summary" /></p>
          </div>
        </xsl:otherwise>
      </xsl:choose>

    </li>
  </xsl:template>

  <xsl:template match="media:group" mode="newsfeed">
    <xsl:param name="full.photo.width" />
    <xsl:param name="thumbnail.width" />
    <xsl:param name="use.lightbox" select="true()" />
    
    <xsl:call-template name="media-link">
      <xsl:with-param name="class" select="'newsfeed'" />
      <xsl:with-param name="width" select="$full.photo.width" />
      <xsl:with-param name="thumbnail.width" select="$thumbnail.width" />
      <xsl:with-param name="use.lightbox" select="$use.lightbox" />
    </xsl:call-template>
  </xsl:template>

  <!-- output an img element for media with the requested width -->
  <xsl:template name="media-image">
    <xsl:param name="class" />
    <xsl:param name="width" />
    <xsl:variable name="image" select="media:thumbnail[@width=$width]" />

    <xsl:if test="$image">
      <img src="{$image/@url}" 
           alt="{media:title[@type='plain']}" 
           width="{$width}" 
           height="{$image/@height}">
        <xsl:if test="$class and normalize-space($class)!=''">
          <xsl:attribute name="class">
            <xsl:value-of select="$class" />
          </xsl:attribute>
        </xsl:if>
      </img>
    </xsl:if>
  </xsl:template>

  <!-- the "full" image for this image as a link in the gallery -->
  <xsl:template name="media-link">
    <xsl:param name="class" />
    <xsl:param name="width" />
    <xsl:param name="thumbnail.width" />
    <xsl:param name="use.lightbox" select="true()" />

    <xsl:variable name="image" select="(media:thumbnail[@width=$width] | media:content[@width=$width])[position()=1]" />

    <a href="{$image/@url}" title="{media:title[@type='plain']}">
      <xsl:if test="$use.lightbox">
        <xsl:attribute name="rel">
          <xsl:value-of select="concat('lightbox', $class)" />
        </xsl:attribute>
      </xsl:if>

      <xsl:if test="$class and normalize-space($class)!=''">
        <xsl:attribute name="class">
          <xsl:value-of select="$class" />
        </xsl:attribute>
      </xsl:if>

      <xsl:if test="$thumbnail.width and $thumbnail.width &gt; 0">
        <xsl:call-template name="media-image">
          <xsl:with-param name="class" select="'thumbnail'" />
          <xsl:with-param name="width" select="$thumbnail.width" />
        </xsl:call-template>
      </xsl:if>
    </a>
  </xsl:template>



</xsl:stylesheet>
