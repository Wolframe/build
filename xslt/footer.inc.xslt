<?xml version="1.0" encoding="ISO-8859-1" ?>
<!DOCTYPE stylesheet [
  <!ENTITY % w3centities-f PUBLIC "-//W3C//ENTITIES Combined Set//EN//XML"
      "http://www.w3.org/2003/entities/2007/w3centities-f.ent">
  %w3centities-f;
]>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name="footer">
  <xsl:param name="base" select="/page/@base"/>
    
<!-- Footer -->
<div class="wrapper row2">
	<div id="footer" class="clear">
<!--
		<div class="one_quarter first">
			<h2 class="footer_title">Solutions</h2>
			<nav class="footer_nav">
				<ul class="nospace">
					<li><a href="#">Simple CRM</a></li>
					<li><a href="#">Bug reporting tool</a></li>
					<li><a href="#">Message broker</a></li>
				</ul>
			</nav>
		</div>
-->
<!--		<div class="one_quarter">-->
		<div class="one_third first">
			<h2 class="footer_title">Documentation</h2>
			<nav class="footer_nav">
				<ul class="nospace">
					<li><a href="/documentation.html">User documentation</a></li>
					<li><a href="/documentation.html">Developer documentation</a></li>
				</ul>
			</nav>
		</div>

<!--		<div class="one_quarter">-->
		<div class="one_third">
			<h2 class="footer_title">Downloads</h2>
			<nav class="footer_nav">
				<ul class="nospace">
					<li><a href="/downloads_wolframe.html">Wolframe server</a></li>
					<li><a href="/downloads_wolfclient.html">Wolframe client</a></li>
				</ul>
			</nav>
		</div>

<!--		<div class="one_quarter">-->
		<div class="one_third">
			<h2 class="footer_title">Contact Us</h2>
			<p><strong>Email:</strong> <a href="mailto:contact@wolframe.net">contact@wolframe.net</a></p>
		</div>
	</div>
</div>

<div class="wrapper row4">
	<div id="copyright" class="clear">
		<p class="fl_left">Copyright &copy; 2013 - <a href="#">Project Wolframe</a> - All Rights Reserved</p>
		<p class="fl_right">Template by <a href="http://www.os-templates.com/" title="Free Website Templates">OS Templates</a></p>
	</div>
</div>

<!-- Scripts -->
<script src="http://code.jquery.com/jquery-latest.min.js"></script>
<script src="http://code.jquery.com/ui/1.10.1/jquery-ui.min.js"></script>
<script src="/layout/scripts/jquery-mobilemenu.min.js"></script>
<script src="/layout/scripts/custom.js"></script>

</xsl:template>
  
</xsl:stylesheet>
