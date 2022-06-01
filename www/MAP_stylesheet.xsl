<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
  <xsl:template match="/">
    <html>
<head>
      <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css" integrity="sha384-B0vP5xmATw1+K9KRQjQERJvTumQW0nPEzvF6L/Z6nronJ3oUOFUFpCjEUQouq2+l" crossorigin="anonymous"/>
    <link rel="stylesheet" href="style.css"/>
    <title>Mattereum Asset Passport <xsl:value-of select="asset_passport/title"/></title>
    </head>
    </html>

    <body>
      <main>
        <div class="container">
          <div class="mt-1" style="padding-bottom:80px;">
            <div class="row">
              <h1>Mattereum Asset Passport<br/>
                <xsl:value-of select="asset_passport/title"/>
              </h1>
              <p>This is a Mattereum Asset Passport. It is used to prove the value of physical objects. The physical objects    are usually stored in a vault and bound to an Ethereum blockchain NFT. The Mattereum Asset Passport is made of a series of signed legal statements about the valuable attributes of the physical object. In most cases, you can buy a legal warranty on these legal statements, protecting you in case of error or fraud.</p>
              <p></p>
              <p>Disputes are heard using special legal procedures, suitable for resolving disputes of these kinds, made binding under the 1958 New York Convention on Arbitration.</p>
              <p>
                <img>
                  <xsl:attribute name="src">
                    <xsl:value-of select="asset_passport/image"/>
                  </xsl:attribute>
                </img>
                <br/>See this object's
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="asset_passport/NFTLink"/>
                  </xsl:attribute>
                  NFT Listing Page
                </a>
              </p>
            </div>

            <xsl:for-each select="asset_passport/warranty">
              <div class="row warranty m-2 p-2">
                <div class="col">
                  <h2>
                    <xsl:attribute name="id">
                      <xsl:value-of select="title"/>
                    </xsl:attribute>
                    Warranty <xsl:value-of select="position()"/>: <xsl:value-of select="title"/>
                  </h2>
                </div>
                <div class="w-100"></div>
                <div class="col">
                  <xsl:for-each select="warranty_section">
                    <div class="w-100"/>
                    <div class="col">
                      <h3><xsl:value-of select="section_title"/></h3>
                      <dl>
                        <xsl:for-each select="content">
                        <dt><xsl:value-of select="title"/></dt>
                        <xsl:for-each select="paragraph">
                        <dd><p><xsl:value-of select="."/></p></dd>
                        </xsl:for-each>
                        <xsl:for-each select="email">
                        <dd><p><xsl:value-of select="."/></p></dd><!--TODO add href here for mailto functionality-->
                        </xsl:for-each>
                        <xsl:for-each select="image">
                          <dd><p>
                            <img>
                              <xsl:attribute name="src">
                                <xsl:value-of select="image_address"/>
                              </xsl:attribute>
                              <xsl:attribute name="alt">
                                <xsl:value-of select="alt_text"/>
                              </xsl:attribute>
                            </img>
                          </p></dd>
                        </xsl:for-each><!--end of image-->
                        <xsl:for-each select="link">
                          <dd><p>
                            <a>
                              <xsl:attribute name="href">
                                <xsl:value-of select="link_address"/>
                              </xsl:attribute>
                              <xsl:value-of select="text"/>
                            </a>
                          </p></dd>
                        </xsl:for-each><!--end link-->
                        <xsl:for-each select="list">
                          <ol><dd>
                            <xsl:for-each select="paragraph">
                              <li><p>
                                <xsl:value-of select="."/>
                              </p></li>
                            </xsl:for-each><!--end list paragraph-->
                            <xsl:for-each select="email">
                              <li><p>
                                <xsl:value-of select="."/><!--TODO add href-->
                                </p></li>
                              </xsl:for-each><!--end list email-->
                              <xsl:for-each select="link">
                                <li><p>
                                 <a>
                              <xsl:attribute name="href">
                                <xsl:value-of select="link_address"/>
                              </xsl:attribute>
                              <xsl:value-of select="text"/>
                                 </a>
                                  </p></li>
                                </xsl:for-each> <!--end list link-->
                                <xsl:for-each select="image">
                                  <li><p>
                                     <img>
                              <xsl:attribute name="src">
                                <xsl:value-of select="image_address"/>
                              </xsl:attribute>
                              <xsl:attribute name="alt">
                                <xsl:value-of select="alt_text"/>
                              </xsl:attribute>
                                     </img>
                                  </p></li>
                                </xsl:for-each><!--end list image-->
                          </dd></ol>
                        </xsl:for-each><!--end list-->
                      </xsl:for-each><!--end content-->
                      </dl>
                    </div>
                  </xsl:for-each><!--end section-->
                  <xsl:for-each select="contract">
                    <div class="w-100"/>
                    <div class="col">
                      <h3>contract</h3>
                      <p class="contract_link">
                        <xsl:for-each select="link">
                        <a>
                          <xsl:attribute name="href">
                            <xsl:value-of select="link_address"/>
                          </xsl:attribute>
                          <xsl:value-of select="text"/>
                          </a><br/>
                        </xsl:for-each>
                        </p>
                      <dl>
                        <xsl:for-each select="content">
                        <dt><xsl:value-of select="title"/></dt>
                        <xsl:for-each select="paragraph">
                        <dd><p><xsl:value-of select="."/></p></dd>
                        </xsl:for-each>
                        <xsl:for-each select="email">
                        <dd><p><xsl:value-of select="."/></p></dd><!--TODO add href here for mailto functionality-->
                        </xsl:for-each>
                        <xsl:for-each select="image">
                          <dd><p>
                            <img>
                              <xsl:attribute name="src">
                                <xsl:value-of select="image_address"/>
                              </xsl:attribute>
                              <xsl:attribute name="alt">
                                <xsl:value-of select="alt_text"/>
                              </xsl:attribute>
                            </img>
                          </p></dd>
                        </xsl:for-each><!--end of image-->
                        <xsl:for-each select="link">
                          <dd><p>
                            <a>
                              <xsl:attribute name="href">
                                <xsl:value-of select="link_address"/>
                              </xsl:attribute>
                              <xsl:value-of select="text"/>
                            </a>
                          </p></dd>
                        </xsl:for-each><!--end link-->
                        <xsl:for-each select="list">
                          <ol><dd>
                            <xsl:for-each select="paragraph">
                              <li><p>
                                <xsl:value-of select="."/>
                              </p></li>
                            </xsl:for-each><!--end list paragraph-->
                            <xsl:for-each select="email">
                              <li><p>
                                <xsl:value-of select="."/><!--TODO add href-->
                                </p></li>
                              </xsl:for-each><!--end list email-->
                              <xsl:for-each select="link">
                                <li><p>
                                 <a>
                              <xsl:attribute name="href">
                                <xsl:value-of select="link_address"/>
                              </xsl:attribute>
                              <xsl:value-of select="text"/>
                                 </a>
                                  </p></li>
                                </xsl:for-each> <!--end list link-->
                                <xsl:for-each select="image">
                                  <li><p>
                                     <img>
                              <xsl:attribute name="src">
                                <xsl:value-of select="image_address"/>
                              </xsl:attribute>
                              <xsl:attribute name="alt">
                                <xsl:value-of select="alt_text"/>
                              </xsl:attribute>
                                     </img>
                                  </p></li>
                                </xsl:for-each><!--end list image-->
                          </dd></ol>
                        </xsl:for-each><!--end list-->
                      </xsl:for-each><!--end content-->
                      </dl>
                    </div>
                  </xsl:for-each><!--end contract-->
                  <xsl:for-each select="certifier">
                    <div class="w-100"></div>
                    <div class="col">
                      <h3>Issuer</h3>
                      <div class="vcard">
                        <div class="vcard_photo">
                          <img height="100">
                            <xsl:attribute name="src">
                              <xsl:value-of select="image/image_address"/>
                              </xsl:attribute>
                          </img>
                        </div>
                        <div class="vcard-text">
                        <div class="vcard_name">
                          <xsl:value-of select="name"/>
                        </div>
                        </div>
                        <div class="vcard_address">
                          <xsl:value-of select="address"/>
                        </div>
                        </div>
                    </div>
                  </xsl:for-each>
                </div>
              </div>
            </xsl:for-each><!--end warranty-->
        </div>
        </div>
      </main>
      <nav class="navbar">
        <a class="navbar-brand">
          <img width="213" height="42">
            <xsl:attribute name="src">
              <xsl:value-of select="mattereum_logos-1.jpg"/>
            </xsl:attribute>
          </img>
        </a>
        <div class="warranties">warranties
        </div>
<ol class="navbar-nav me-auto mb-2 mb-1g-0">
        <xsl:for-each select="asset_passport/warranty">
          <li class="nav-item">
            <a class="nav-link">
              <xsl:attribute name="href">
                #<xsl:value-of select="title"/>
              </xsl:attribute>
              <xsl:value-of select="title"/>
              </a>
          </li>
        </xsl:for-each>
        <li>
          <a class="nav-link" href="https://mattereum.com/terms-conditions">Terms and conditions</a>
        </li>
        </ol>
      </nav>
      <div class="logo-bar logo-bar-top"></div>
      <div class="logo-bar logo-bar-bottom"></div>

      <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    </body>


  </xsl:template>
</xsl:stylesheet>
