<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mf="http://www.example.org/myFunction/" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:function name="mf:normalize-slashs" as="xs:string">
        <xsl:param name="url"/>
        <xsl:choose>
            <xsl:when test="substring($url, string-length($url))='/'">
                <xsl:value-of select="$url" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($url, '/')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
