<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:date-converter="ext1"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="date-converter">

    <!-- URL prefix for news item links -->
    <xsl:variable name="website_prefix">http://www.myorganization.org</xsl:variable>
    <!-- File extension used -->
    <xsl:variable name="file_extension">.html</xsl:variable>
    <!-- RSS extension to use -->
    <xsl:variable name="rss_extension">.rss</xsl:variable>
    <!-- Name of RSS generator -->
    <xsl:variable name="rss_generator">Cascade Server</xsl:variable>
    <!-- Web master's email address -->
    <xsl:variable name="web_master">webmaster@myorganization.org</xsl:variable>
    <!-- Path in the CMS -->
    <xsl:variable name="site_path"/>
    <!-- Match on the root index block -->
    <xsl:template match="system-index-block">
        <xsl:variable name="currentPage" select="calling-page/system-page"/>
        <rss version="2.0">
            <channel>
                <!-- write RSS header information -->
                <xsl:apply-templates mode="current" select="$currentPage"/>
                <!-- write top 20 items, make sure pages have last-published-on element -->
                <xsl:apply-templates select="//system-page[not(@current)]">
                    <xsl:sort order="descending" select="start-date"/>
                </xsl:apply-templates>
            </channel>
        </rss>
    </xsl:template>
    <!-- Matches on the current system page, the news type page -->
    <xsl:template match="system-page" mode="current">
        <title>
            <xsl:call-template name="get-name-from-metadata"/>
        </title>
        <link>
            <xsl:value-of select="$website_prefix"/>
            <xsl:value-of select="substring-after(path,$site_path)"/>
            <xsl:value-of select="$rss_extension"/>
        </link>
        <description>
            <xsl:value-of select="summary"/>
        </description>
        <pubDate>
            <xsl:choose>
                <xsl:when test="start-date">
                    <xsl:value-of select="date-converter:convertDate(number(last-published-on))"/>
                </xsl:when>
                <xsl:when test="created-on">
                    <xsl:value-of select="date-converter:convertDate(number(created-on))"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </pubDate>
        <generator>
            <xsl:value-of select="$rss_generator"/>
        </generator>
        <webMaster>
            <xsl:value-of select="$web_master"/>
        </webMaster>
    </xsl:template>
    <!-- Match on first 20 invidiual news item pages -->
    <xsl:template match="system-page">
        <xsl:if test="position() &lt 21">
            <item>
                <title>
                    <xsl:call-template name="get-name-from-metadata"/>
                </title>
                <link>
                    <xsl:value-of select="$website_prefix"/>
                    <xsl:value-of select="substring-after(path,$site_path)"/>
                    <xsl:value-of select="$file_extension"/>
                </link>
                <description>
                    <xsl:choose>
                        <xsl:when test="summary">
                            <xsl:value-of select="summary"/>
                        </xsl:when>
                        <xsl:when test="description">
                            <xsl:value-of select="description"/>
                        </xsl:when>
                        <xsl:otherwise>
                            No description.
                        </xsl:otherwise>
                    </xsl:choose>
                </description>
                <pubDate>
                    <xsl:choose>
                        <xsl:when test="start-date">
                            <xsl:value-of select="date-converter:convertDate(number(start-date))"/>
                        </xsl:when>
                        <xsl:when test="created-on">
                            <xsl:value-of select="date-converter:convertDate(number(created-on))"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </pubDate>
                <guid><xsl:value-of select="$website_prefix"/>/<xsl:value-of select="@id"/></guid>
            </item>
        </xsl:if>
    </xsl:template>
    <xsl:template name="get-name-from-metadata">
        <xsl:choose>
            <xsl:when test="title">
                <xsl:value-of select="title"/>
            </xsl:when>
            <xsl:when test="display-name">
                <xsl:value-of select="display-name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Xalan component for date conversion from CMS date format to RSS 2.0 pubDate format -->
    <xalan:component functions="convertDate" prefix="date-converter">
        <xalan:script lang="javascript">
            function convertDate(date)
            {
            var d = new Date(date);
            // Splits date into components
            var temp = d.toString().split(' ');
            // timezone difference to GMT
            var timezone = temp[5].substring(3);
            // RSS 2.0 valid pubDate format
            var retString = temp[0] + ', ' + temp[2] + ' ' + temp[1] + ' ' + temp[3] + ' ' + temp[4] + ' ' + timezone;
            return retString;
            }
        </xalan:script>
    </xalan:component>
</xsl:stylesheet>