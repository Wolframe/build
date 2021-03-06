<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet [
 <!ENTITY nbsp "&#xa0;">
 <!ENTITY copy "&#169;">
]>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name="footer">
  <xsl:param name="base" select="/page/@base"/>
    
<!-- Footer -->
<div class="wrapper row2">
	<div id="footer" class="clear">
		<div class="one_third first">
			<h2 class="footer_title">Documentation</h2>
			<nav class="footer_nav">
				<ul class="nospace">
					<li><a href="/documentation.html">User documentation</a></li>
					<li><a href="/documentation.html">Developer documentation</a></li>
				</ul>
			</nav>
		</div>

		<div class="one_third">
			<h2 class="footer_title">Downloads</h2>
			<nav class="footer_nav">
				<ul class="nospace">
					<li><a href="/downloads/downloads_wolframe.html">Wolframe server</a></li>
					<li><a href="/downloads/downloads_wolfclient.html">Wolframe client</a></li>
				</ul>
			</nav>
		</div>

		<div class="one_third">
			<h2 class="footer_title">Contact Us</h2>
<!--
				<nav class="footer_nav">
				<ul class="nospace">
					<li><strong>Email:</strong> <a href="/mailto:contact@wolframe.net">contact@wolframe.net</a></li>
					<li>
						<a id="googleplus-bttn" href="http://plus.google.com/116915890857205562872?prsrc=3" rel="publisher" target="_top" style="text-decoration:none;">
							<span>Google+</span></a>
						<a  id="linkedin-bttn" href="#" target="_top" style="text-decoration:none;">
							<span>LinkedIn</span></a>
						<a id="twitter-bttn" href="http://twitter.com/ProjectWolframe" target="_top" style="text-decoration:none;">
							<span>twitter</span></a>
						<a id="rss-bttn" href="#" target="_top" style="text-decoration:none;">
							<span>rss</span></a>
					</li>
					<li>
						<a href="https://twitter.com/ProjectWolframe" class="twitter-follow-button" data-show-count="false" data-show-screen-name="false">Follow @ProjectWolframe</a>
						<div class="g-follow" data-annotation="none" data-height="20" data-href="http://plus.google.com/116915890857205562872" data-rel="publisher"></div>
						<div class="g-plusone" data-href="http://www.wolframe.net" data-size="medium"></div>
					</li>
				</ul>
			</nav>
-->			
		</div>
	</div>
</div>

<div class="wrapper row4">
	<div id="copyright" class="clear">
		<p class="fl_left">Copyright &copy; 2013 - <a href="#">Project Wolframe</a> - All Rights Reserved</p>
		<p class="fl_right"><a href="/copyright.html">Copyright and web credits</a> - Template by <a href="http://www.os-templates.com/" title="Free Website Templates">OS Templates</a></p>
	</div>
</div>

<!-- Scripts -->
<script src="http://code.jquery.com/jquery-latest.min.js"></script>
<script src="http://code.jquery.com/ui/1.10.1/jquery-ui.min.js"></script>
<script>window.jQuery || document.write('\x3Cscript src="/layout/scripts/jquery-latest.min.js">\x3C\/script>\
\x3Cscript src="/layout/scripts/jquery-ui.min.js">\x3C\/script>')</script>
<script>jQuery(document).ready(function($){ $('img').removeAttr('width height'); });</script>
<script src="/layout/scripts/jquery-mobilemenu.min.js"></script>
<script src="/layout/scripts/custom.js"></script>
<!-- Tweeter follow script -->
<script>
	!function( d, s, id )	{
		var js, fjs = d.getElementsByTagName(s)[0], p = /^http:/.test(d.location)?'http':'https';
		if( !d.getElementById( id ))	{
			js = d.createElement( s );
			js.id = id;
			js.src = p + '://platform.twitter.com/widgets.js';
			fjs.parentNode.insertBefore( js,fjs );
		}
	} ( document, 'script', 'twitter-wjs' );
</script>

<!-- Google +1, follow -->
<!--<script type="text/javascript">
	window.___gcfg = {
		lang: 'en-US',
		parsetags: 'onload'
	};
	( function()	{
		var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
		po.src = 'https://apis.google.com/js/plusone.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
	}) ();
</script>
-->
</xsl:template>
  
</xsl:stylesheet>
