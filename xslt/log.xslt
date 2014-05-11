<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:output method="html" version="1.1" encoding="UTF-8" indent="no"/>

  <xsl:include href="page.inc.xslt"/>
  <xsl:include href="images.xslt"/>

  <xsl:template match="/page">
    <xsl:call-template name="page">
      <xsl:with-param name="base" select="/page/@base"/>
      <xsl:with-param name="title" select="'Build Result'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="log">
    <h2>Build Result&#160;<xsl:value-of select="/page/@project"/>,&#160;rev.&#160;<xsl:value-of select="revision"/>,&#160;<xsl:value-of select="arch"/>,&#160;<xsl:value-of select="platform"/></h2>
    <table>
      <tr>
        <td class="label">OSC version:
        </td>
        <td>
          <xsl:value-of select="revision"/>
        </td>
      </tr>
      <tr>
        <td class="label">GIT version:
        </td>
        <td>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="/page/@scmBaseUrl"/><xsl:value-of select="substring(git_version,1,10)"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="substring(git_version,1,10)"/>
              </xsl:attribute>
            <xsl:value-of select="git_version"/>
          </xsl:element>
        </td>
      </tr>
      <tr>
        <td class="label">Architecture:
        </td>
        <td>
          <xsl:value-of select="arch"/>
        </td>
      </tr>
      <tr>
        <td class="label">Platform:
        </td>
        <td>
          <xsl:value-of select="platform"/>&#160;
          <xsl:call-template name="image">
            <xsl:with-param name="src" select="platform"/>
          </xsl:call-template>
        </td>
      </tr>
      <tr>
        <td class="label">Build state:
        </td>
        <xsl:variable name="orig_status" select="status"/>
        <xsl:variable name="status">
          <xsl:choose>
            <xsl:when test="$orig_status='succeeded'">ok</xsl:when>
            <xsl:when test="$orig_status='succeeded*'">ok</xsl:when>
            <xsl:when test="$orig_status='failed'">fail</xsl:when>
            <xsl:when test="$orig_status='failed*'">fail</xsl:when>
            <xsl:when test="$orig_status='unresolvable'">fail</xsl:when>
            <xsl:when test="$orig_status='disabled'">-</xsl:when>
            <xsl:otherwise>??</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="td">
          <xsl:attribute name="class">status_<xsl:value-of select="$status"/></xsl:attribute>
          <xsl:value-of select="$orig_status"/>
        </xsl:element>
      </tr>
      <tr>
        <td class="label">Build logfile:
        </td>
        <td>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="/page/@base"/>docs/<xsl:value-of select="revision"/>/<xsl:value-of select="arch"/>/<xsl:value-of select="platform"/>/log.txt
            </xsl:attribute>
            raw text
          </xsl:element>
        </td>
      </tr>
    </table>
    <xsl:choose>
      <xsl:when test="/page/@browser='lynx2'">
      <pre>
        <xsl:value-of select="tail"/>
      </pre>
      </xsl:when>
      <xsl:otherwise>
<script language="javascript" type="text/JavaScript">
	var maxPos = <xsl:value-of select="/page/@fileSize"/>;
	var pos = <xsl:value-of select="/page/@fileSize"/> - 20;

	function createRequest() {
		var request = null;
		try {
			request = new XMLHttpRequest( );
		} catch( tryMS ) {
			try {
				request = new ActiveXObject( "Msxml2.XMLHTTP" );
			} catch( tryMS2 ) {
				try {
					request = new ActiveXObject("Microsoft.XMLHTTP"); 
				} catch( failed ) {
					request = null;
				}
			}
		}

		if( request == null ) {
			alert( "Error creating request object!" );
		} else {
			return request;
		}
	}

	var request = createRequest( );

	function scrollTo( pos ) {
		if( pos &lt; 20 ) {
			document.getElementById( "watchFirst" ).disabled = true; 
			document.getElementById( "watchPrev" ).disabled = true; 
		} else {
			document.getElementById( "watchFirst" ).disabled = false; 
			document.getElementById( "watchPrev" ).disabled = false; 
		}

		if( pos &gt; maxPos - 20 ) {
			document.getElementById( "watchNext" ).disabled = true; 
			document.getElementById( "watchLast" ).disabled = true; 
		} else {
			document.getElementById( "watchNext" ).disabled = false; 
			document.getElementById( "watchLast" ).disabled = false; 
		}

		filter = document.getElementById( "filter" ).value;

		var url = "<xsl:value-of select="/page/@absoluteSelf"/>log.php?file=<xsl:value-of select="/page/@base"/>docs/<xsl:value-of select="revision"/>/<xsl:value-of select="arch"/>/<xsl:value-of select="platform"/>/log.txt&amp;pos=" + pos + "&amp;filter=" + encodeURIComponent( filter );
		request.open( "GET", url, true );
		request.onreadystatechange = updatePage;
		request.send( null );
	}

	function updatePage( ) {
		if( request.readyState == 4 ) {
			if( request.status == 200 ) {
				var text = request.responseText;
				var lines = text.split( '\n' );
				var nofLines = lines[0];
				lines.splice( 0, 1 );
				var newtext = lines.join( '\n' );
				log.innerHTML = '<pre>' + newtext + '</pre>';
				adaptBoundaries( nofLines );
			} else {
				alert( "Error! Request status is " + request.status );
			}
		}
	}

	function adaptBoundaries( nofLines ) {
		if( nofLines == 0 ) {
			filterAlert.innerHTML = "no matches";
		} else {
			filterAlert.innerHTML = nofLines + " lines match";
		}

		allDisabled = ( nofLines == 0 );
                document.getElementById( "watchSlider" ).disabled = allDisabled;
                document.getElementById( "watchFirst" ).disabled = allDisabled;
                document.getElementById( "watchNext" ).disabled = allDisabled;
                document.getElementById( "watchPrev" ).disabled = allDisabled;
                document.getElementById( "watchLast" ).disabled = allDisabled;
		if( pos &lt; 20 ) {
			document.getElementById( "watchFirst" ).disabled = true; 
			document.getElementById( "watchPrev" ).disabled = true; 
		} else {
			document.getElementById( "watchFirst" ).disabled = false; 
			document.getElementById( "watchPrev" ).disabled = false; 
		}
		if( pos &gt; maxPos - 20 ) {
			document.getElementById( "watchNext" ).disabled = true; 
			document.getElementById( "watchLast" ).disabled = true; 
		} else {
			document.getElementById( "watchNext" ).disabled = false; 
			document.getElementById( "watchLast" ).disabled = false; 
		}

		if( nofLines != maxPos ) {
			maxPos = nofLines;
			document.getElementById( "watchSlider" ).max = maxPos;
		}
		if( pos > nofLines ) {
			pos = 1;
			scrollToPos( pos );
		}

	}

	function filterLog( ) {
		pos = document.getElementById( "watchSlider" ).value;
		scrollTo( pos );
	}

	function watchFirst( ) {
		pos = 1;
		scrollTo( pos );
		document.getElementById( "watchSlider" ).value = pos;
	}

	function watchPrev( ) {
		pos = pos - 20;
		if( pos &lt; 1 ) {
			pos = 1;
		}
		scrollTo( pos );
		document.getElementById( "watchSlider" ).value = pos;
	}

	function watchNext( ) {
		pos = pos + 20;
		if( pos &gt; maxPos - 20 ) {
			pos = maxPos - 20;
		}
		scrollTo( pos );
		document.getElementById( "watchSlider" ).value = pos;
	}

	function watchLast( ) {
		pos = maxPos;
		scrollTo( pos );
		document.getElementById( "watchSlider" ).value = pos;
	}

	function updateSlider( value ) {
		if( pos == value ) {
			return;
		}
		pos = value;
		scrollTo( pos );
	}

</script>
	<table><tr>
	  <td style="width:100px;" class="label">Filter:</td>
	  <td>
		<input id="filter" type="text" onKeyUp="filterLog( );"/>
		<div style="float: right" id="filterAlert"/>
          </td>
        </tr></table>
        <table><tr>
          <td style="width:100px;" class="label">Scroll logfile:</td>
                        <td>
                                <input type="button" style="width:40px; 0px" id="watchFirst" value="&lt;&lt;" onClick="watchFirst( );"/>
				&#160;
                                <input type="button" style="width:40px; 0px" id="watchPrev" value="&lt;" onClick="watchPrev( );"/>
				&#160;
                                  <xsl:element name="input">
					<xsl:attribute name="style">width: 60%</xsl:attribute>
					<xsl:attribute name="type">range</xsl:attribute>
					<xsl:attribute name="id">watchSlider</xsl:attribute>
					<xsl:attribute name="min">1</xsl:attribute>
					<xsl:attribute name="step">20</xsl:attribute>
					<xsl:attribute name="max">
						<xsl:value-of select="/page/@fileSize"/>
					</xsl:attribute>
					<xsl:attribute name="value">
						<xsl:value-of select="/page/@fileSize"/>
					</xsl:attribute>
					<xsl:attribute name="onChange">updateSlider( this.value );</xsl:attribute>
                                  </xsl:element>
				&#160;
                                <input type="button" style="width:40px; 0px" id="watchNext" value="&gt;" disabled="disabled" onClick="watchNext( );"/>
				&#160;
                                <input type="button" style="width:40px; 0px" id="watchLast" value="&gt;&gt;" disabled="disabled" onClick="watchLast( );"/>
				&#160;
                        </td>
        </tr></table>
        <div class="description" id="log" style="width:100%; height:90%; overflow:auto;">
          <pre>
            <xsl:value-of select="tail"/>
          </pre>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
