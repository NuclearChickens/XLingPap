<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:variable name="chosenContentControl"
        select="//contentControlChoices/contentControlChoice[@active='yes']"/>
    <xsl:variable name="chosenContentTypes" select="id($chosenContentControl/@exclude)"/>
    <xsl:variable name="splitParts">1</xsl:variable>
    <!-- If SplitParts is 0, this transform will export content to a 
        single text file [filename]_wiki.text.
    If splitParts is 1, it does much more:
    1. Export each Lingpaper Part and Appendix as a separate file.
    2. Make sectionRefs across pages work.
    3. Make all numbered sections explicit, as TikiWiki can't handle continuing section numbering on a new page.
    4. Add "Navigation" links to the top and bottom of each page.
    5. Produce a table of contents file.
    6. Produce an XML index, you zip up all of the exports and import this archive into Tikiwiki instead of copy/paste.-->
    <xsl:template match="xlingpaper">
        <xsl:apply-templates/>
        <xsl:if test="$splitParts=1">
            <xsl:call-template name="makeTikiContents"/>
            <xsl:call-template name="makeTikiXML"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="lingPaper">
        <xsl:if test="$splitParts='1'">
            <xsl:call-template name="makeTikiParts"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template name="getHardSectionNumberOf">
        <xsl:param name="nodes"/>
        <xsl:if test="$nodes[ancestor-or-self::chapter]">
            <xsl:number level="any" select="$nodes" count="chapter | chapterInCollection" format="1"/>
        </xsl:if>
        <xsl:if test="$nodes[ancestor::chapter]">
            <xsl:text>.</xsl:text>
            <xsl:number level="single" select="$nodes" count="section1" format="1"/>
        </xsl:if>
        <xsl:if test="$nodes[ancestor::section1]">
            <xsl:text>.</xsl:text>
            <xsl:number level="single" select="$nodes" count="section2" format="1"/>
        </xsl:if>
        <xsl:if test="$nodes[ancestor::section2]">
            <xsl:text>.</xsl:text>
            <xsl:number level="single" select="$nodes" count="section3" format="1"/>
        </xsl:if>
        <xsl:text>: </xsl:text>
    </xsl:template>
    <xsl:template name="getHardSectionNumber">
        <xsl:if test="ancestor-or-self::chapter">
            <xsl:number level="any" count="chapter | chapterInCollection" format="1"/>
        </xsl:if>
        <xsl:if test="ancestor::chapter">
            <xsl:text>.</xsl:text>
            <xsl:number level="single" count="section1" format="1"/>
        </xsl:if>
        <xsl:if test="ancestor::section1">
            <xsl:text>.</xsl:text>
            <xsl:number level="single" count="section2" format="1"/>
        </xsl:if>
        <xsl:if test="ancestor::section2">
            <xsl:text>.</xsl:text>
            <xsl:number level="single" count="section3" format="1"/>
        </xsl:if>
        <xsl:text>: </xsl:text>
    </xsl:template>
    <xsl:template match="part">
        <xsl:variable name="splitPart">
            <xsl:number level="single" count="part" format="1"/>
        </xsl:variable>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="chapter">
        <xsl:text>&#xa;!</xsl:text>
        <xsl:if test="$splitParts='0'">
            <xsl:text>#</xsl:text>
        </xsl:if>
        <xsl:if test="$splitParts='1'">
            <xsl:call-template name="getHardSectionNumber"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="section1">
        <xsl:text>&#xa;----</xsl:text>
        <xsl:text>&#xa;!!</xsl:text>
        <xsl:if test="$splitParts='0'">
            <xsl:text>#</xsl:text>
        </xsl:if>
        <xsl:if test="$splitParts='1'">
            <xsl:call-template name="getHardSectionNumber"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="section2">
        <xsl:text>&#xa;!!!</xsl:text>
        <xsl:if test="$splitParts='0'">
            <xsl:text>#</xsl:text>
        </xsl:if>
        <xsl:if test="$splitParts='1'">
            <xsl:call-template name="getHardSectionNumber"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="section3">
        <xsl:text>&#xa;!!!!</xsl:text>
        <xsl:if test="$splitParts='0'">
            <xsl:text>#</xsl:text>
        </xsl:if>
        <xsl:if test="$splitParts='1'">
            <xsl:call-template name="getHardSectionNumber"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="link">
        <xsl:text>(( </xsl:text>
        <xsl:value-of select=".[@href]"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="./text()"/>
        <xsl:text> ))</xsl:text>
    </xsl:template>
    <xsl:template match="object">
        <xsl:choose>
            <xsl:when test="@type='tsub'">
                <xsl:text>''</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>''</xsl:text>
            </xsl:when>
            <xsl:when test="@type='tItalic'">
                <xsl:text>''</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>''</xsl:text>
            </xsl:when>
            <xsl:when test="@type='tmenu'">
                <xsl:text>__</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>__</xsl:text>
            </xsl:when>
            <xsl:when test="@type='tkey'">
                <xsl:text>__</xsl:text>
                <xsl:apply-templates/>
                <xsl:text>__</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="currentType">
                    <xsl:value-of select="@type"/>
                </xsl:variable>
                <xsl:value-of
                    select="/xlingpaper/styledPaper[1]/lingPaper[1]/types[1]/type[@id=$currentType]/@before"/>
                <xsl:apply-templates/>
                <xsl:value-of
                    select="/xlingpaper/styledPaper[1]/lingPaper[1]/types[1]/type[@id=$currentType]/@after"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="titleContentChoices">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="titleContent">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="secTitle">
        <xsl:if test="((parent::part) or (parent::appendix)) and parent::part[1]">
            <xsl:text>!</xsl:text>
        </xsl:if>
        <xsl:if test="((parent::part) or (parent::appendix)) and not(parent::part[1])">
            <xsl:text>&#xa;!</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
    <xsl:template match="p">
        <xsl:text>&#xa;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="shortTitle">
        <!-- Skip This -->
    </xsl:template>
    <xsl:template match="framedUnit">
        <xsl:text>&#xa;{BOX(bg="#FFE6FF" width="60%")}</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>{BOX}</xsl:text>
    </xsl:template>
    <xsl:template match="blockquote">
        <xsl:text>&#xa;%%%</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>%%%</xsl:text>
    </xsl:template>
    <xsl:template match="table">
        <xsl:text>&#xa;||</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>||</xsl:text>
    </xsl:template>
    <xsl:template match="th">
        <xsl:text>|</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="td">
        <xsl:if test="preceding-sibling::*">
            <xsl:text>|</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:variable name="cleanedBracket" select="replace(., '\[', '[[')"/>
        <xsl:value-of select="$cleanedBracket"/>
    </xsl:template>
    <xsl:template match="tr">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::tr">
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="br">
        <xsl:choose>
            <xsl:when test="name(..)='td'">
                <xsl:text>%%%</xsl:text>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#xd;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="li">
        <xsl:choose>
            <xsl:when test="name(..)='ul'">
                <xsl:text>&#xa;* </xsl:text>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="name(..)='ol'">
                <xsl:text>&#xa;# </xsl:text>
                <xsl:apply-templates/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="img">
        <xsl:text>{img src="</xsl:text>
        <xsl:text>https://raw.githubusercontent.com/erros84/PTManuals/master/</xsl:text>
        <xsl:value-of select="translate(@src, '\\', '/')"/>
        <xsl:text>" class=img-responsive}</xsl:text>
    </xsl:template>
    <xsl:template match="frontMatter"/>
    <xsl:template match="backMatter">
        <xsl:if test="$splitParts='1'">
            <xsl:message>Matched backmatter element</xsl:message>
            <xsl:call-template name="makeTikiAppendices"/>
        </xsl:if>
    </xsl:template>
    <xsl:variable name="folderPath">
        <xsl:text>WikiOut/</xsl:text>
        <xsl:choose>
            <xsl:when test="//frontMatter[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()">
                <xsl:value-of select="//frontMatter[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
            </xsl:when>
            <xsl:when test="//frontMatter[1]/shortTitle[1]/text()">
                <xsl:value-of select="//frontMatter[1]/shortTitle[1]/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Manual</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>/</xsl:text>
    </xsl:variable>
    <xsl:template match="sectionRef">
        <xsl:call-template name="parseSectionRef"/>
    </xsl:template>
    <xsl:template name="parseSectionRef">
        <xsl:text>((</xsl:text>
        <xsl:variable name="sref">
            <xsl:value-of select="@sec"/>
        </xsl:variable>
        <xsl:variable name="secname">
            <xsl:choose>
                <xsl:when test="//*[@id=$sref]/secTitle[1]/titleContentChoices[1]/titleContent[1]">
                    <xsl:value-of select="//*[@id=$sref]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="//*[@id=$sref]/secTitle[1]">
                    <xsl:value-of select="//*[@id=$sref]/secTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$splitParts='1'">
            <xsl:variable name="linkparent">
                <xsl:value-of select="//*[@id=$sref]/ancestor-or-self::part"/>
            </xsl:variable>
            <xsl:if test="ancestor::part/@id!=$linkparent">
                <xsl:choose>
                    <xsl:when test="//*[@id=$sref]/ancestor-or-self::part/shortTitle/titleContentChoices[1]/titleContent[1]">
                        <xsl:value-of
                            select="//*[@id=$sref]/ancestor-or-self::part/shortTitle/titleContentChoices[1]/titleContent[1]/text()"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="//*[@id=$sref]/ancestor-or-self::part/shortTitle/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>|</xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:call-template name="tikifyLink">
            <xsl:with-param name="unclean" select="$secname"/>
        </xsl:call-template>
        <xsl:text>|</xsl:text>
        <xsl:if test="$splitParts='1'">
            <xsl:call-template name="getHardSectionNumberOf">
                <xsl:with-param name="nodes" select="//*[@id=$sref]" />
            </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="$secname"/>
        <xsl:text>))</xsl:text>
    </xsl:template>
    <xsl:template name="makeTikiContents">
        <xsl:variable name="projectname">
            <xsl:choose>
                <xsl:when test="//frontMatter[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()">
                    <xsl:value-of select="//frontMatter[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="//frontMatter[1]/shortTitle[1]/text()">
                    <xsl:value-of select="//frontMatter[1]/shortTitle[1]/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Manual</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="contentsLabel">
            <xsl:choose>
                <xsl:when test="//frontMatter[1]/contents[1]/@label">
                <xsl:value-of
                    select="//frontMatter[1]/contents[1]/@label"/>
            </xsl:when>
            <xsl:otherwise><xsl:text>Contents</xsl:text></xsl:otherwise>
            </xsl:choose>    
        </xsl:variable>
        <xsl:result-document method="text" href="{$folderPath}\{$projectname}_{$contentsLabel}\{$projectname}_{$contentsLabel}">
            <xsl:choose>
                <xsl:when test="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/title[1]/titleContentChoices[1]/titleContent[1]">
                    <xsl:text>!</xsl:text>
                    <xsl:value-of select="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/title[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                    <xsl:text>&#xa;</xsl:text> 
                </xsl:when>
                <xsl:when test="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/title[1]">
                    <xsl:text>!</xsl:text>
                    <xsl:value-of select="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/title[1]/text()"/>
                    <xsl:text>&#xa;</xsl:text> 
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/subtitle[1]/titleContentChoices[1]/titleContent[1]">
                    <xsl:text>!!</xsl:text>
                    <xsl:value-of select="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/subtitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                    <xsl:text>&#xa;</xsl:text> 
                </xsl:when>
                <xsl:when test="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/subtitle[1]">
                    <xsl:text>!!</xsl:text>
                    <xsl:value-of select="/xlingpaper/styledPaper[1]/lingPaper[1]/frontMatter[1]/subtitle[1]/text()"/>
                    <xsl:text>&#xa;</xsl:text> 
                </xsl:when>
            </xsl:choose>
            
            <xsl:text>!!</xsl:text>
            <xsl:value-of select="$contentsLabel"/>
            <xsl:text>&#xa;</xsl:text>    
            <xsl:for-each select="//part|//chapter|//section1|//section2|//section3|//appendix">
                <xsl:variable name="secname">
                    <xsl:choose>
                        <xsl:when test="./secTitle[1]/titleContentChoices[1]/titleContent[1]">
                            <xsl:value-of select="./secTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                        </xsl:when>
                        <xsl:when test="./secTitle[1]">
                            <xsl:value-of select="./secTitle[1]/text()"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="name(.)='chapter'">
                        <xsl:text>&#xa;*</xsl:text>
                    </xsl:when>
                    <xsl:when test="name(.)='section1'">
                        <xsl:text>&#xa;**</xsl:text>
                    </xsl:when>
                    <xsl:when test="name(.)='section2'">
                        <xsl:text>&#xa;***</xsl:text>
                    </xsl:when>
                    <xsl:when test="name(.)='section3'">
                        <xsl:text>&#xa;****</xsl:text>
                    </xsl:when>
                    <xsl:when test="name(.)='appendix'">
                        <xsl:text>&#xa;Appendix: </xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>((</xsl:text>
                <xsl:choose>
                    <xsl:when test="./ancestor-or-self::part/shortTitle/titleContentChoices[1]/titleContent[1]">
                        <xsl:value-of select="./ancestor-or-self::part/shortTitle/titleContentChoices[1]/titleContent[1]/text()"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./ancestor-or-self::part/shortTitle/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                <xsl:when test="./ancestor-or-self::appendix/shortTitle/titleContentChoices[1]/titleContent[1]">
                        <xsl:value-of select="./ancestor-or-self::appendix/shortTitle/titleContentChoices[1]/titleContent[1]/text()"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./ancestor-or-self::appendix/shortTitle/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>|</xsl:text>
                <!-- put these things here-->
                <xsl:call-template name="tikifyLink">
                    <xsl:with-param name="unclean" select="$secname"/>
                </xsl:call-template>
                <xsl:text>|</xsl:text>
                <xsl:call-template name="getHardSectionNumber"/>
                <xsl:value-of select="$secname"/>
                <xsl:text>))</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="tikifyLink">
        <xsl:param name="unclean"/>
        <xsl:variable name="secNameUnderscore" select="replace($unclean, '[^0-9a-zA-Z:.-]+', '_')"/>
        <xsl:variable name="secNamePunct" select="replace($secNameUnderscore, '([\.:])', '\\$1')"/>
        <xsl:variable name="secNameParenL" select="replace($secNamePunct, '\(', '~040~')"/>
        <xsl:variable name="secNameParenR" select="replace($secNameParenL, '\)', '~041~')"/>
        <xsl:variable name="cleanedBracket" select="replace($secNameParenR, '\[', '[[')"/>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$cleanedBracket"/>
    </xsl:template>
    <xsl:template name="makeTikiXML">
        <xsl:if test="$splitParts='1'">
            <xsl:result-document method="xml" href="{$folderPath}wiki.xml">
                <xsl:element name="pages">
                        <xsl:element name="page">
                            <xsl:variable name="projectname">
                                <xsl:choose>
                                    <xsl:when test="//frontMatter[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()">
                                        <xsl:value-of select="//frontMatter[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                                    </xsl:when>
                                    <xsl:when test="//frontMatter[1]/shortTitle[1]/text()">
                                        <xsl:value-of select="//frontMatter[1]/shortTitle[1]/text()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Manual</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="contentsLabel">
                                <xsl:choose>
                                    <xsl:when test="//frontMatter[1]/contents[1]/@label">
                                        <xsl:value-of
                                            select="//frontMatter[1]/contents[1]/@label"/>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:text>Contents</xsl:text></xsl:otherwise>
                                </xsl:choose>    
                            </xsl:variable>
                            <xsl:attribute name="zip">
                                <xsl:value-of select="$projectname"/>
                                <xsl:text>_</xsl:text>
                                <xsl:value-of select="$contentsLabel"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$projectname"/>
                                <xsl:text>_</xsl:text>
                                <xsl:value-of select="$contentsLabel"/>
<!--                                <xsl:text>.txt</xsl:text>-->
                            </xsl:attribute>
                            <xsl:element name="name">
                                <xsl:value-of select="$projectname"/>
                                <xsl:text>_</xsl:text>
                                <xsl:value-of select="$contentsLabel"/>
                            </xsl:element>
                            <xsl:element name="creator">
                                <xsl:text>matthew_lee</xsl:text>
                            </xsl:element>
                            <xsl:element name="user">
                                <xsl:text>matthew_lee</xsl:text>
                            </xsl:element>
                            <xsl:element name="is_html">
                                <xsl:text>0</xsl:text>
                            </xsl:element>
                            <xsl:element name="wysiwyg">
                                <xsl:text>n</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    <xsl:for-each select="//part">
                        <xsl:element name="page">
                            <xsl:variable name="partNum">
                                <xsl:number level="any" count="part" format="1"/>
                            </xsl:variable>
                            <xsl:variable name="filename">
                                <xsl:choose>
                                    <xsl:when
                                        test="//part[$partNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()">
                                        <xsl:value-of
                                            select="//part[$partNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"
                                        />
                                    </xsl:when>
                                    <xsl:when test="//part[$partNum+0]/shortTitle[1]/text()">
                                        <xsl:value-of
                                            select="//part[$partNum+0]/shortTitle[1]/text()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>XLingPaperPDFTemp/</xsl:text>
                                        <xsl:value-of select="$partNum+0"/>
                                        <xsl:text>_tiki.txt</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:attribute name="zip">
                                <xsl:value-of select="$filename"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$filename"/>
                            </xsl:attribute>
                            <xsl:element name="name">
                                <xsl:value-of select="$filename"/>
                            </xsl:element>
                            <xsl:element name="creator">
                                <xsl:text>matthew_lee</xsl:text>
                            </xsl:element>
                            <xsl:element name="user">
                                <xsl:text>matthew_lee</xsl:text>
                            </xsl:element>
                            <xsl:element name="is_html">
                                <xsl:text>0</xsl:text>
                            </xsl:element>
                            <xsl:element name="wysiwyg">
                                <xsl:text>n</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:for-each select="//appendix">
                        <xsl:element name="page">
                            <xsl:variable name="appendixNum">
                                <xsl:number level="any" count="appendix" format="1"/>
                            </xsl:variable>
                            <xsl:variable name="filename">
                                <xsl:choose>
                                    <xsl:when
                                        test="//appendix[$appendixNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                                        <xsl:value-of
                                            select="//appendix[$appendixNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"
                                        />
                                    </xsl:when>
                                    <xsl:when
                                        test="//appendix[$appendixNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                                        <xsl:value-of
                                            select="//appendix[$appendixNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"
                                        />
                                    </xsl:when>
                                    <xsl:when
                                        test="//appendix[$appendixNum+0]/shortTitle[1]/text()!=''">
                                        <xsl:value-of
                                            select="//appendix[$appendixNum+0]/shortTitle[1]/text()"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>XLingPaperPDFTemp/</xsl:text>
                                        <xsl:value-of select="$appendixNum+0"/>
                                        <xsl:text>_tiki.txt</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:attribute name="zip">
                                <xsl:attribute name="zip">
                                    <xsl:value-of select="$filename"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$filename"/>
<!--                                    <xsl:text>.txt</xsl:text>-->
                                </xsl:attribute>
                            </xsl:attribute>
                            <xsl:element name="name">
                                <xsl:value-of select="$filename"/>
                            </xsl:element>
                            <xsl:element name="creator">
                                <xsl:text>matthew_lee</xsl:text>
                            </xsl:element>
                            <xsl:element name="user">
                                <xsl:text>matthew_lee</xsl:text>
                            </xsl:element>
                            <xsl:element name="is_html">
                                <xsl:text>0</xsl:text>
                            </xsl:element>
                            <xsl:element name="wysiwyg">
                                <xsl:text>n</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    <xsl:template name="makeTikiNav">
        <xsl:variable name="tempNextShort">
            <xsl:choose>
                <xsl:when test="./following-sibling::*[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="./following-sibling::*[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"
                    />
                </xsl:when>
                <xsl:when test="./following-sibling::*[1]/shortTitle[1]/text()!=''">
                    <xsl:value-of select="./following-sibling::*[1]/shortTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempPrevShort">
            <xsl:choose>
                <xsl:when test="./preceding-sibling::*[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="./preceding-sibling::*[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"
                    />
                </xsl:when>
                <xsl:when test="./preceding-sibling::*[1]/shortTitle[1]/text()!=''">
                    <xsl:value-of select="./preceding-sibling::*[1]/shortTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempNextTitle">
            <xsl:choose>
                <xsl:when test="./following-sibling::*[1]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="./following-sibling::*[1]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="./following-sibling::*[1]/secTitle[1]/text()!=''">
                    <xsl:value-of select="./following-sibling::*[1]/secTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempPrevTitle">
            <xsl:choose>
                <xsl:when test="./preceding-sibling::*[1]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="./preceding-sibling::*[1]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="./preceding-sibling::*[1]/secTitle[1]/text()!=''">
                    <xsl:value-of select="./preceding-sibling::*[1]/secTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempFirstAppendixTitle">
            <xsl:choose>
                <xsl:when test="//appendix[1]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="//appendix[1]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="//appendix[1]/secTitle[1]/text()!=''">
                    <xsl:value-of select="//appendix[1]/secTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempFirstAppendixShort">
            <xsl:choose>
                <xsl:when test="//appendix[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="//appendix[1]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="//appendix[1]/shortTitle[1]/text()!=''">
                    <xsl:value-of select="//appendix[1]/shortTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempLastPartTitle">
            <xsl:choose>
                <xsl:when test="//part[last()]/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="(//part[last()])/secTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="//part[last()]/secTitle[1]/text()!=''">
                    <xsl:value-of select="(//part[last()])/secTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tempLastPartShort">
            <xsl:choose>
                <xsl:when test="(//part[last()])/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                    <xsl:value-of select="(//part[last()])/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                </xsl:when>
                <xsl:when test="(//part[last()])/shortTitle[1]/text()!=''">
                    <xsl:value-of select="(//part[last()])/shortTitle[1]/text()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="./ancestor-or-self::part">
            <xsl:choose>
                <xsl:when test="not(./preceding-sibling::part)">
                    <!-- First Part, No Previous -->
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempNextShort"/>
                    <xsl:text>|</xsl:text>
                    <xsl:value-of select="$tempNextTitle"/>
                    <xsl:text> --&gt; ))&#xa;</xsl:text>
                </xsl:when>
                <xsl:when test="not(./following-sibling::part)">
                    <!-- last part -->
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempPrevShort"/>
                    <xsl:text>|&lt;-- </xsl:text>
                    <xsl:value-of select="$tempPrevTitle"/>
                    <xsl:text>))&#xa;</xsl:text>
                    <xsl:text>|</xsl:text>
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempFirstAppendixShort"/>
                    <xsl:text>|</xsl:text>
                    <xsl:value-of select="$tempFirstAppendixTitle"/>
                    <xsl:text> --&gt; ))&#xa;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <!--  middle part -->
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempPrevShort"/>
                    <xsl:text>|&lt;-- </xsl:text>
                    <xsl:value-of select="$tempPrevTitle"/>
                    <xsl:text>)) </xsl:text>
                    <xsl:text>|</xsl:text>
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempNextShort"/>
                    <xsl:text>|</xsl:text>
                    <xsl:value-of select="$tempNextTitle"/>
                    <xsl:text> --&gt; ))&#xa;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="./ancestor-or-self::appendix">
            <xsl:variable name="appNum">
                <xsl:number level="any" count="part" format="1"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(./preceding-sibling::appendix)">
                    <!-- First Appendix -->
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempLastPartShort"/>
                    <xsl:text>|&lt;-- </xsl:text>
                    <xsl:value-of select="$tempLastPartTitle"/>
                    <xsl:text>)) </xsl:text>
                    <xsl:text>|</xsl:text>
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempNextShort"/>
                    <xsl:text>|</xsl:text>
                    <xsl:value-of select="$tempNextTitle"/>
                    <xsl:text>--&gt; ))&#xa;</xsl:text>
                </xsl:when>
                <xsl:when test="not(./following-sibling::appendix)">
                    <!-- Last Appendix -->
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempPrevShort"/>
                    <xsl:text>|&lt;-- </xsl:text>
                    <xsl:value-of select="$tempPrevTitle"/>
                    <xsl:text>))&#xa;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Middle Appendix -->
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempPrevShort"/>
                    <xsl:text>|&lt;-- </xsl:text>
                    <xsl:value-of select="$tempPrevTitle"/>
                    <xsl:text>)) </xsl:text>
                    <xsl:text>|</xsl:text>
                    <xsl:text>((</xsl:text>
                    <xsl:value-of select="$tempNextShort"/>
                    <xsl:text>|</xsl:text>
                    <xsl:value-of select="$tempNextTitle"/>
                    <xsl:text> --&gt; ))&#xa;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template name="makeTikiParts">
        <xsl:for-each select="part">
            <xsl:variable name="partNum">
                <xsl:number level="any" count="part" format="1"/>
            </xsl:variable>
            <xsl:variable name="filename">
                <xsl:choose>
                    <xsl:when test="//part[$partNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()">
                        <xsl:value-of select="//part[$partNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                    </xsl:when>
                    <xsl:when test="//part[$partNum+0]/shortTitle[1]/text()">
                        <xsl:value-of select="//part[$partNum+0]/shortTitle[1]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>XLingPaperPDFTemp/P</xsl:text>
                        <xsl:value-of select="$partNum"/>
                        <xsl:text>_tiki.txt</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:result-document method="text" href="{$folderPath}{$filename}/{$filename}">
                <xsl:call-template name="makeTikiNav"/>
                <xsl:apply-templates/>
                <xsl:text>&#xa;</xsl:text>
                <xsl:call-template name="makeTikiNav"/>
            </xsl:result-document>
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="makeTikiAppendices">
        <xsl:for-each select="appendix">
            <xsl:variable name="appendixNum">
                <xsl:number level="any" count="appendix" format="1"/>
            </xsl:variable>
            <xsl:variable name="filenamea">
                <xsl:choose>
                    <xsl:when test="//appendix[$appendixNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()!=''">
                        <xsl:value-of
                            select="//appendix[$appendixNum+0]/shortTitle[1]/titleContentChoices[1]/titleContent[1]/text()"/>
                    </xsl:when>
                    <xsl:when test="//appendix[$appendixNum+0]/shortTitle[1]/text()!=''">
                        <xsl:value-of select="//appendix[$appendixNum+0]/shortTitle[1]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>A</xsl:text>
                        <xsl:value-of select="$appendixNum"/>
                        <xsl:text>_tiki.txt</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:result-document method="text" href="{$folderPath}{$filenamea}/{$filenamea}">
                <xsl:call-template name="makeTikiNav"/>
                <xsl:apply-templates/>
                <xsl:text>&#xa;</xsl:text>
                <xsl:call-template name="makeTikiNav"/>
            </xsl:result-document>
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="publisherStyleSheet"/>
    <xsl:template match="contentLayout"/>
    <xsl:template match="contentControl"/>
    <xsl:template match="languages"/>
    <xsl:template match="types"/>
    <xsl:template match="shortTitle"/>
</xsl:stylesheet>
