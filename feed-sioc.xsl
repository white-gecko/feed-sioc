<?xml version="1.0"?>
<!--
        # http://sw.deri.org/svn/sw/2005/08/sioc/xslt/feed-rss1.0.xsl

        # A transformation of any of the following formats to SIOC:
        # - RSS 0.9
        # - RSS 0.9x/2.0
        # - Atom 0.3
        # - Atom 1.0

        # All RDF formats, including RSS 1.0, is output verbatim

        # (c) 2006 Uldis Bojars (SIOC version)
        # (c) 2002-2006 Morten Frederiksen (Feed-RSS1.0-1.6.xsl)
        #     http://purl.org/net/syndication/subscribe/feed-rss1.0-1.6.xsl

        # License: http://www.gnu.org/licenses/gpl
-->
<xsl:transform
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:simple="http://my.netscape.com/rdf/simple/0.9/"
    xmlns:rss="http://purl.org/rss/1.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:content="http://purl.org/rss/1.0/modules/content/"
    xmlns:syn="http://purl.org/rss/1.0/modules/syndication/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:atom="http://purl.org/atom/ns#"
    xmlns:atom1="http://www.w3.org/2005/Atom"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:admin="http://webns.net/mvcb/"
    xmlns:icbm="http://postneo.com/icbm"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:enc="http://purl.oclc.org/net/rss_2.0/enc#"
    xmlns:sioc="http://rdfs.org/sioc/ns#"
    exclude-result-prefixes="simple atom icbm"
    version="1.0">
    <xsl:output
        indent="yes"
        omit-xml-declaration="yes"
        method="xml"/>
    <xsl:namespace-alias
        result-prefix="rss"
        stylesheet-prefix="rss"/>

    <xsl:param name="rss"/>

    <xsl:template match="/">
        <xsl:apply-templates select="/rdf:RDF"/>
        <xsl:apply-templates select="/rss[@version]/channel"/>
        <xsl:apply-templates select="/redirect/newLocation"/>
        <xsl:apply-templates select="/atom:feed[@version='0.3']"/>
        <xsl:apply-templates select="/atom1:feed"/>
    </xsl:template>

    <xsl:template match="/redirect/newLocation">
        <!-- TODO set xml:base -->
        <rdf:RDF>
            <xsl:apply-templates mode="version" select="."/>
            <rdf:Description rdf:about="{$rss}">
                <dc:isReplacedBy rdf:resource="{normalize-space(.)}"/>
            </rdf:Description>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="/atom:feed|/atom1:feed">
        <xsl:if test="atom1:link[@rel='alternate' and @type='text/html' and @href]">
            <xsl:variable name="link" select="mf:normalize-slashs(atom1:link[@rel='alternate' and @type='text/html' and @href]/@href)" />
            <xsl:variable name="feedBase" select="concat(substring($link, 1, string-length($link) - (substring($link, string-length($link))='/')), '/')" />
        </xsl:if>
<!--//
        <xsl:if test="$rss='' and atom1:link[@rel='self' and @type!='text/html' and @href]">
            <xsl:variable name="link" select="atom1:link[@rel='self' and @type!='text/html' and @href]/@href"/>
            <xsl:variable name="feedBase" select="concat(substring($link, 1, string-length($link) - (substring($link, string-length($link))='/')), '/')" />
        </xsl:if>
//-->
        <rdf:RDF xml:base="{$feedBase}">
            <xsl:copy-of select="@xml:lang|@xml:base"/>
            <xsl:apply-templates mode="version" select="."/>
            <sioc:Forum rdf:about="{$link}">
                <xsl:apply-templates select="*"/>
                <xsl:apply-templates select="@xml:lang"/>
                <xsl:for-each select="atom:entry|atom1:entry">
                    <sioc:container_of>
                        <sioc:Post rdf:about="{atom:link[@rel='alternate']/@href}{atom1:id}"/>
                    </sioc:container_of>
                </xsl:for-each>
            </sioc:Forum>
            <xsl:apply-templates mode="item" select="atom:entry|atom1:entry"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template mode="item" match="atom:entry|atom1:entry">
        <sioc:Post rdf:about="{atom:link[@rel='alternate']/@href}{atom1:id}">
            <xsl:copy-of select="@xml:lang|@xml:base"/>
            <xsl:apply-templates select="*"/>
            <xsl:apply-templates select="@xml:lang"/>
        </sioc:Post>
    </xsl:template>

    <xsl:template match="/rdf:RDF">
        <xsl:copy-of select="."/>
<!--//
        <rdf:RDF>
            <xsl:apply-templates mode="version" select="rss:channel|simple:channel"/>
            <xsl:apply-templates mode="rss" select="*"/>
            <xsl:apply-templates select="simple:*"/>
        </rdf:RDF>
//-->
    </xsl:template>

    <xsl:template mode="version" match="rss:channel|channel|simple:channel|newLocation|atom:feed|atom1:feed">
        <xsl:comment>
            <xsl:value-of select="' version=&quot;'"/>
            <xsl:choose>
                <xsl:when test="namespace-uri()='http://purl.org/rss/1.0/'">
                    <xsl:value-of select="'RSS 1.0'"/>
                </xsl:when>
                <xsl:when test="namespace-uri()='http://purl.org/atom/ns#'">
                    <xsl:value-of select="'Atom '"/>
                    <xsl:value-of select="@version"/>
                </xsl:when>
                <xsl:when test="namespace-uri()='http://www.w3.org/2005/Atom'">
                    <xsl:value-of select="'Atom 1.0'"/>
                </xsl:when>
                <xsl:when test="../@version">
                    <xsl:value-of select="'RSS '"/>
                    <xsl:value-of select="../@version"/>
                </xsl:when>
                <xsl:when test="namespace-uri()='http://my.netscape.com/rdf/simple/0.9/'">
                    <xsl:value-of select="'RSS 0.9'"/>
                </xsl:when>
                <xsl:when test="local-name()='newLocation' and normalize-space(.)!=''">
                    <xsl:value-of select="'Redirected'"/>
                </xsl:when>
                <xsl:when test="local-name()='newLocation'">
                    <xsl:value-of select="'Dead'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'?'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="'&quot; '"/>
        </xsl:comment>
    </xsl:template>

    <xsl:template mode="rss" match="rss:channel">
        <sioc:Forum rdf:about="">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="rss" select="node()|text()|comment()"/>
            <xsl:variable name="feedBase" select="''" />
        </sioc:Forum>
    </xsl:template>

    <xsl:template mode="rss" match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="rss" select="node()|text()|comment()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="rss" match="rdf:li">
        <sioc:Post rdf:about="{concat(@resource,@rdf:resource)}"/>
    </xsl:template>

    <xsl:template match="simple:channel">
        <sioc:Forum rdf:about="{simple:link}">
<!--//
            <xsl:if test="simple:link[@href]">
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="atom1:link[@rel='alternate' and @type='text/html' and @href]/@href"/>
                </xsl:attribute>
            </xsl:if>
//-->
            <xsl:apply-templates select="simple:title|simple:description|simple:link"/>
            <xsl:for-each select="../simple:item[normalize-space(simple:link)!='']">
                <sioc:container_of>

                    <sioc:Post rdf:about="{simple:link}"/>
                </sioc:container_of>

            </xsl:for-each>
            <xsl:if test="../simple:image[normalize-space(simple:url)!='']">
                <rss:image rdf:resource="{../simple:image[normalize-space(simple:url)!=''][1]/simple:url}"/>
            </xsl:if>
            <xsl:if test="../simple:textinput[normalize-space(simple:link)!='']">
                <rss:textinput rdf:resource="{../simple:textinput[normalize-space(simple:link)!=''][1]/simple:link}"/>
            </xsl:if>
        </sioc:Forum>
    </xsl:template>

    <xsl:template match="simple:item">
        <xsl:if test="normalize-space(simple:link)!=''">
            <sioc:Post rdf:about="{simple:link}">
                <xsl:apply-templates select="simple:title|simple:description|simple:link"/>
            </sioc:Post>
        </xsl:if>
    </xsl:template>

    <xsl:template match="simple:image">
        <xsl:if test="normalize-space(simple:url)!=''">
            <rss:image rdf:about="{simple:url}">
                <xsl:apply-templates select="simple:url|simple:link|simple:title|simple:description"/>
            </rss:image>
        </xsl:if>
    </xsl:template>

    <xsl:template match="simple:textinput">
        <xsl:if test="normalize-space(simple:link)!=''">
            <rss:textinput rdf:about="{simple:link}">
                <xsl:apply-templates select="simple:name|simple:link|simple:title|simple:description"/>
            </rss:textinput>
        </xsl:if>
    </xsl:template>

    <xsl:template match="icbm:latitude">
        <geo:lat>
            <xsl:value-of select="text()"/>
        </geo:lat>
    </xsl:template>

    <xsl:template match="icbm:longitude">
        <geo:long>
            <xsl:value-of select="text()"/>
        </geo:long>
    </xsl:template>

    <xsl:template match="dc:*|dcterms:*">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:title|atom:link/@title|atom1:title|atom1:link/@title|simple:title|simple:description|simple:link|simple:url|simple:name">
        <xsl:element name="{concat('dc:',local-name(.))}">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:modified|atom:created|atom:issued">
        <xsl:element name="{concat('dcterms:',local-name(.))}">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template priority="1.0" match="atom1:*/@xml:lang">
        <dc:language>
            <xsl:value-of select="."/>
        </dc:language>
    </xsl:template>

    <xsl:template priority="1.0" match="dc:date.Taken">
        <dcterms:created>
            <xsl:value-of select="."/>
        </dcterms:created>
    </xsl:template>

    <xsl:template priority="1.0" match="atom1:published">
        <dcterms:created>
            <xsl:value-of select="."/>
        </dcterms:created>
    </xsl:template>

    <xsl:template priority="1.0" match="atom1:updated">
        <dcterms:modified>
            <xsl:value-of select="."/>
        </dcterms:modified>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:name|atom1:name">
        <xsl:element name="{concat('foaf:',local-name(.))}">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:url|atom1:url">
        <foaf:homepage rdf:resource="{.}"/>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:email">
        <foaf:mbox rdf:resource="mailto:{.}"/>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:link[@rel='alternate' and @type='text/html']|atom1:link[@href and (@type='text/html' or count(@*)=1)]">
<!--//
        <sioc:link>
            <xsl:value-of select="@href"/>
        </sioc:link>
//-->
        <sioc:link rdf:resource="{@href}"/>
    </xsl:template>

    <xsl:template priority="0.5" match="atom:link">
        <dcterms:references>
            <rdf:Description rdf:about="{@href}">
                <xsl:apply-templates select="@*"/>
            </rdf:Description>
        </dcterms:references>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:link/@type">
        <dc:format>
            <xsl:value-of select="."/>
        </dc:format>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:link/@rel|atom:id">
        <dc:identifier>
            <xsl:value-of select="."/>
        </dc:identifier>
    </xsl:template>

    <xsl:template priority="1.1" match="atom1:category[@scheme and @term]">
        <dc:subject rdf:resource="{@scheme}{@term}"/>
        <sioc:topic>
            <skos:Concept rdf:about="{@scheme}{@term}">
                <rdfs:label>{@term}</rdfs:label>
            </skos:Concept>
        </sioc:topic>
    </xsl:template>

    <xsl:template priority="1.0" match="atom1:category[@term]">
        <xsl:element name="dc:subject">
            <xsl:value-of select="normalize-space(@term)"/>
        </xsl:element>

        <xsl:element name="sioc:topic">
            <skos:Concept>
                <rdfs:label><xsl:value-of select="normalize-space(@term)"/></rdfs:label>
            </skos:Concept>
        </xsl:element>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:generator[@url and @version]">
        <admin:generatorAgent rdf:resource="{@url}?v={@version}"/>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:author|atom:contributor|atom1:author">
        <foaf:maker>
            <foaf:Person>
                <xsl:if test="atom:name">
                    <xsl:attribute name="rdf:nodeID">
                        <xsl:value-of select="translate(./atom:name/text(), ' ', '')"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="atom1:name">
                    <xsl:attribute name="rdf:nodeID">
                        <xsl:value-of select="translate(./atom1:name/text(), ' ', '')"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="*"/>
            </foaf:Person>
        </foaf:maker>
    </xsl:template>

    <xsl:template priority="1.0" match="atom1:subtitle">
        <dc:description>
            <xsl:value-of select="."/>
        </dc:description>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:tagline|atom:summary">
        <dc:description>
            <xsl:value-of select="."/>
        </dc:description>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:copyright|atom1:rights">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:content[@mode='escaped']">
        <content:encoded>
            <xsl:copy-of select="@xml:lang"/>
            <xsl:value-of select="."/>
        </content:encoded>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:content[not(@mode) or @mode='xml']|atom1:content[@type='html' or @type='xhtml']">
        <content:encoded>
            <xsl:copy-of select="@xml:lang|@xml:base"/>
            <xsl:value-of select="."/>
        </content:encoded>
    </xsl:template>

    <xsl:template priority="1.0" match="atom:content[@type='multipart/alternative']">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template priority="0.1" match="atom:*|atom1:*|atom:*/@*|atom1:*/@*">
    </xsl:template>

    <xsl:template match="channel">
        <xsl:variable name="link" select="link" />
        <xsl:variable name="feedBase" select="concat(substring($link, 1, string-length($link) - (substring($link, string-length($link))='/')), '/')" />
        <rdf:RDF xml:base="{$feedBase}">
            <xsl:apply-templates mode="version" select="."/>
            <sioc:Forum rdf:about="{$link}">
                <xsl:apply-templates select="title|link|description|language|copyright|webMaster|webmaster|managingEditor|managingeditor|pubDate|pubdate|lastBuildDate|lastbuilddate|category[@domain='Syndic8']"/>
                <xsl:copy-of select="dc:*|dcterms:*|syn:*"/>
                <xsl:for-each select="item">
                    <sioc:container_of>

                        <sioc:Post>
                            <xsl:attribute name="rdf:about">
                                <xsl:apply-templates mode="link" select="."/>
                            </xsl:attribute>
                        </sioc:Post>
                    </sioc:container_of>

                </xsl:for-each>
                <xsl:if test="image[normalize-space(url)!='']">
                    <rss:image rdf:resource="{image[normalize-space(url)!=''][1]/url}"/>
                </xsl:if>
                <xsl:if test="textinput[normalize-space(link)!='']">
                    <rss:textinput rdf:resource="{textinput[normalize-space(link)!=''][1]/link}"/>
                </xsl:if>
            </sioc:Forum>
            <xsl:apply-templates select="item|image[normalize-space(url)!='']|textinput[normalize-space(link)!='']"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="item">
        <sioc:Post>
            <xsl:attribute name="rdf:about">
                <xsl:apply-templates mode="link" select="."/>
            </xsl:attribute>
            <xsl:apply-templates select="icbm:latitude|icbm:longitude|link|title|description|language|category|pubDate|pubdate|lastBuildDate|lastbuilddate"/>
            <xsl:if test="not(link) and normalize-space(guid[not(@isPermaLink='false')])!=''">
                <sioc:link>
                    <xsl:value-of select="guid[not(@isPermaLink='false')]"/>
                </sioc:link>
            </xsl:if>
            <xsl:if test="not(title)">
                <dc:title/>
            </xsl:if>
            <xsl:copy-of select="dc:*|dcterms:*|content:*"/>
        </sioc:Post>
    </xsl:template>

    <xsl:template mode="rss" match="rss:items">
        <xsl:for-each select="rdf:Seq/rdf:li">
            <sioc:container_of>
                <sioc:Post>
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="@rdf:resource"/>
                    </xsl:attribute>
                </sioc:Post>
            </sioc:container_of>
        </xsl:for-each>
    </xsl:template>

    <xsl:template mode="rss" match="dc:creator">
        <foaf:maker>
            <foaf:Person>
                <foaf:name>
                    <xsl:value-of select="."/>
                </foaf:name>
            </foaf:Person>
        </foaf:maker>
    </xsl:template>

    <xsl:template mode="rss" match="dc:date">
        <dcterms:created>
            <xsl:value-of select="."/>
        </dcterms:created>
    </xsl:template>

    <xsl:template mode="rss" match="rss:description">
        <content:encoded>
            <xsl:value-of select="."/>
        </content:encoded>
    </xsl:template>

    <xsl:template mode="rss" match="rss:title">
        <dc:title>
            <xsl:value-of select="."/>
        </dc:title>
    </xsl:template>

    <xsl:template mode="rss" match="rss:link">
        <sioc:link>
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </sioc:link>
    </xsl:template>


    <xsl:template mode="rss" match="rss:item">
        <sioc:Post>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="@rdf:about"/>
<!--//
                <xsl:apply-templates mode="link" select="."/>
//-->
            </xsl:attribute>
            <xsl:apply-templates mode="rss"/>
        </sioc:Post>
    </xsl:template>

    <xsl:template mode="link" match="item">
        <xsl:choose>
            <xsl:when test="normalize-space(guid[not(@isPermaLink='false')])!=''">
                <xsl:value-of select="guid[not(@isPermaLink='false')]"/>
            </xsl:when>
            <xsl:when test="normalize-space(link)!=''">
                <xsl:value-of select="link"/>
                <xsl:variable name="link" select="link/text()"/>
                <xsl:if test="(count(../item[link/text()=$link]) != 1) and (normalize-space(guid[@isPermaLink='false'])!='')">
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="guid[@isPermaLink='false']"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$rss"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="generate-id(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="link" match="channel|image|textinput">
        <xsl:value-of select="link[1]"/>
    </xsl:template>

    <xsl:template match="image">
        <xsl:if test="normalize-space(url)!=''">
            <rss:image rdf:about="{url}">
                <xsl:apply-templates select="url|link|title|description"/>
            </rss:image>
        </xsl:if>
    </xsl:template>

    <xsl:template match="textinput">
        <xsl:if test="normalize-space(link)!=''">
            <rss:textinput rdf:about="{link}">
                <xsl:apply-templates select="name|link|title|description"/>
            </rss:textinput>
        </xsl:if>
    </xsl:template>

    <xsl:template match="link">
        <xsl:element name="{concat('sioc:',name(.))}">
            <xsl:attribute name="rdf:resource">
                <xsl:apply-templates mode="link" select=".."/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="name|url|title|description">
        <xsl:element name="{concat('dc:',name(.))}">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="language">
        <xsl:element name="{concat('dc:',name(.))}">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="copyright">
        <xsl:element name="dc:rights">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="webMaster|webmaster">
        <xsl:element name="dc:publisher">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="managingEditor|managingeditor">
        <xsl:element name="dc:creator">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="category[@domain='Syndic8']">
        <xsl:element name="dcterms:isReferencedBy">
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="'http://www.syndic8.com/feedinfo.php?FeedID='"/>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="category">
        <xsl:element name="dc:subject">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>

        <xsl:element name="sioc:topic">
            <skos:Concept>
                <rdfs:label><xsl:value-of select="normalize-space(.)"/></rdfs:label>
            </skos:Concept>
        </xsl:element>
    </xsl:template>

    <xsl:template match="pubDate|pubdate">
        <xsl:apply-templates mode="rfc2822-w3cdtf" select=".">
            <xsl:with-param name="name" select="'dcterms:created'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="lastBuildDate|lastbuilddate">
        <xsl:apply-templates mode="rfc2822-w3cdtf" select=".">
            <xsl:with-param name="name" select="'dcterms:modified'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template mode="rfc2822-w3cdtf" match="*">
        <xsl:param name="name" select="'dc:date'"/>
        <xsl:if test="contains(.,',') and string-length(normalize-space(substring-before(.,',')))=3">
            <xsl:variable name="dmyhisz" select="normalize-space(substring-after(.,','))"/>
            <!-- Fetch date of month. -->
            <xsl:if test="contains($dmyhisz,' ') and string-length(substring-before($dmyhisz,' '))&lt;=2">
                <xsl:variable name="d" select="substring-before($dmyhisz,' ')"/>
                <xsl:variable name="myhisz" select="normalize-space(substring-after($dmyhisz,' '))"/>
                <!-- Validate date of month, fetch and translate month name to month number. -->
                <xsl:if test="string-length(translate($d,'0123456789',''))=0 and contains($myhisz,' ') and string-length(substring-before($myhisz,' '))=3">
                    <xsl:variable name="m-temp" select="translate(substring-before($myhisz,' '),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
                    <xsl:variable name="yhisz" select="normalize-space(substring-after($myhisz,' '))"/>
                    <xsl:variable name="m">
                        <xsl:choose>
                            <xsl:when test="$m-temp='jan'">
                                <xsl:value-of select="'1'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='feb'">
                                <xsl:value-of select="'2'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='mar'">
                                <xsl:value-of select="'3'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='apr'">
                                <xsl:value-of select="'4'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='may'">
                                <xsl:value-of select="'5'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='jun'">
                                <xsl:value-of select="'6'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='jul'">
                                <xsl:value-of select="'7'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='aug'">
                                <xsl:value-of select="'8'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='sep'">
                                <xsl:value-of select="'9'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='oct'">
                                <xsl:value-of select="'10'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='nov'">
                                <xsl:value-of select="'11'"/>
                            </xsl:when>
                            <xsl:when test="$m-temp='dec'">
                                <xsl:value-of select="'12'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Validate month, fetch (possibly translating) year. -->
                    <xsl:if test="string-length($m)!=0 and contains($yhisz,' ')">
                        <xsl:variable name="y-temp" select="substring-before($yhisz,' ')"/>
                        <xsl:variable name="hisz" select="normalize-space(substring-after($yhisz,' '))"/>
                        <xsl:variable name="y">
                            <xsl:choose>
                                <xsl:when test="string-length(translate($y-temp,'0123456789',''))=0 and string-length($y-temp)=2 and $y-temp &lt; 70">
                                    <xsl:value-of select="concat('20',$y-temp)"/>
                                </xsl:when>
                                <xsl:when test="string-length(translate($y-temp,'0123456789',''))=0 and string-length($y-temp)=2 and $y-temp &gt;= 70">
                                    <xsl:value-of select="concat('19',$y-temp)"/>
                                </xsl:when>
                                <xsl:when test="string-length(translate($y-temp,'0123456789',''))=0 and string-length($y-temp)=4">
                                    <xsl:value-of select="$y-temp"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- Validate year, fetch time, fetch and translate (valid) time zone. -->
                        <xsl:if test="string-length($y)!=0 and contains($hisz,' ')">
                            <xsl:variable name="his" select="substring-before($hisz,' ')"/>
                            <xsl:variable name="z" select="normalize-space(substring-after($hisz,' '))"/>
                            <xsl:variable name="offset">
                                <xsl:choose>
                                    <xsl:when test="$z='GMT' or $z='+0000'">
                                        <xsl:value-of select="'Z'"/>
                                    </xsl:when>
                                    <xsl:when test="string-length($z)=5 and $z!='-0000' and (substring($z,1,1)='-' or substring($z,1,1)='+') and (substring($z,2,1)='0' or substring($z,2,1)='1') and string-length(translate($z,'0123456789',''))=1">
                                        <xsl:value-of select="concat(substring($z,1,3),':',substring($z,4,2))"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <!-- Validate time and time zone. -->
                            <xsl:choose>
                                <xsl:when test="string-length($his)=8 and string-length(translate($his,'0123456789',''))=2 and string-length(translate($his,':',''))=6 and string-length($offset)!=0">
                                    <xsl:element name="{$name}">
                                        <xsl:value-of select="concat($y,'-',format-number($m,'00'),'-',format-number($d,'00'),'T',$his,$offset)"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:comment>
                                        <xsl:value-of select="."/>
                                    </xsl:comment>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>

</xsl:transform>
