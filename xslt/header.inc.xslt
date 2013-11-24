<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name="html-header">
  <xsl:param name="base" select="/page/@base"/>
  <xsl:param name="title"/>
  
	<head>
		<title><xsl:value-of select="$title"/></title>
		<meta charset="iso-8859-1" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico" />

		<link href="{$base}layout/styles/main.css" rel="stylesheet" type="text/css" media="all" />
		<link href="{$base}layout/styles/mediaqueries.css" rel="stylesheet" type="text/css" media="all" />
		<link href="{$base}layout/styles/build.css" rel="stylesheet" type="text/css" media="all" />

<!--[if lt IE 9]>
		<link href="{$base}layout/styles/ie/ie8.css" rel="stylesheet" type="text/css" media="all" />
		<script src="{$base}layout/scripts/ie/css3-mediaqueries.min.js"></script>
		<script src="{$base}layout/scripts/ie/html5shiv.min.js"></script>
<![endif]-->

	</head>

</xsl:template>

<xsl:template name="header">
  <xsl:param name="base" select="/page/@base"/>
  <xsl:param name="title"/>
  <xsl:param name="js-modules"/>

<div class="wrapper row1">
	<header id="header" class="full_width clear">
		<div id="header-logo">
			<h1><a href="/index.html">Project Wolframe</a></h1>
			<h2>The Straight Path to Successful Projects</h2>
		</div>
		<div id="header-contact">
			<ul class="list none">
				<li><span class="fa fa-envelope"></span> <a href="mailto:contact@wolframe.net">contact@wolframe.net</a></li>
<!--				<li><span class="fa fa-phone"></span> +xx xxx xxxxxxxxxx</li> -->
			</ul>
			<ul class="list none">
				<li class="icons"><a id="googleplus-bttn" href="http://plus.google.com/116915890857205562872?prsrc=3" rel="publisher" target="_top" style="text-decoration:none;">
					<span>Google+</span></a></li>
				<li class="icons"><a  id="linkedin-bttn" href="#" target="_top" style="text-decoration:none;">
					<span>LinkedIn</span></a></li>
				<li class="icons"><a id="twitter-bttn" href="http://twitter.com/ProjectWolframe" target="_top" style="text-decoration:none;">
					<span>twitter</span></a></li>
				<li class="icons"><a id="rss-bttn" href="#" target="_top" style="text-decoration:none;">
					<span>rss</span></a></li>
			</ul>
		</div>
	</header>
</div>

<!-- ################################################################################################ -->
<div class="wrapper row2">
	<nav id="topnav">
		<ul class="clear">
<!-- BEGIN MENU -->
			<li><a href="/index.html" title="Home">Home</a></li>
<!--
			<li><a href="/solutions.html" title="Solutions">Solutions</a></li>
-->
			<li><a href="/downloads.html" title="Downloads">Downloads</a></li>
			<li><a href="/documentation.html" title="Documentation">Documentation</a></li>
			<li><a class="drop" href="/support.html" title="Support">Support</a>
				<ul>
					<li><a href="/faq.html" title="FAQ">FAQ</a></li>
					<li><a href="http://www.wolframe.ch/mailman/listinfo" title="Mailing lists">Mailing lists</a></li>
				</ul>
			</li>
			<li class="active"><a class="drop" href="/development/development_daily_builds.html" title="Smoke tests">Smoke tests</a>
				<ul>
					<li><a href="/develop/builds/Wolframe/" title="Wolframe">Wolframe</a></li>
					<li class="last-child"><a href="/develop/builds/wolfclient/" title="wolfclient">wolfclient</a></li>
				</ul>
			</li>
			<li class="last-child"><a href="/contact.html" title="Contact Us">Contact Us</a></li>
		</ul>
	</nav>
</div>
<!-- ################################################################################################ -->

</xsl:template>

</xsl:stylesheet>
