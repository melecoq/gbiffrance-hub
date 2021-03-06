<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 11/02/14
  Time: 10:52 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<g:set var="startPageTime" value="${System.currentTimeMillis()}"/>
<g:set var="queryDisplay" value="${sr?.queryTitle?:searchRequestParams?.displayString?:''}"/>
<g:set var="searchQuery" value="${grailsApplication.config.skin.useAlaBie ? 'taxa' : 'q'}"/>
<!DOCTYPE html>
<html>
<head>
    <meta name="svn.revision" content="${meta(name: 'svn.revision')}"/>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <meta name="section" content="search"/>
    <title><g:message code="list.title" default="Search"/>: ${sr?.queryTitle?.replaceAll("<(.|\n)*?>", '')} | <alatag:message code="search.heading.list" default="Search results"/> | ${grailsApplication.config.skin.orgNameLong}</title>
    %{--<script src="http://maps.google.com/maps/api/js?v=3.2&sensor=false"></script>--}%
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <r:require modules="search, leaflet, slider, qtip, nanoscroller, amplify, moment, mapCommon"/>
    <g:if test="${grailsApplication.config.skin.useAlaBie?.toBoolean()}">
        <r:require module="bieAutocomplete"/>
    </g:if>
    <script type="text/javascript">
        // single global var for app conf settings
        <g:set var="fqParamsSingleQ" value="${(params.fq) ? ' AND ' + params.list('fq')?.join(' AND ') : ''}"/>
        <g:set var="fqParams" value="${(params.fq) ? "&fq=" + params.list('fq')?.join('&fq=') : ''}"/>
        <g:set var="searchString" value="${raw(sr?.urlParameters).encodeAsURL()}"/>
        var BC_CONF = {
            contextPath: "${request.contextPath}",
            serverName: "${grailsApplication.config.serverName}${request.contextPath}",
            searchString: "${searchString}", //  JSTL var can contain double quotes // .encodeAsJavaScript()
            facetQueries: "${fqParams.encodeAsURL()}",
            facetDownloadQuery: "${searchString}${fqParamsSingleQ}",
            queryString: "${queryDisplay.encodeAsJavaScript()}",
            bieWebappUrl: "${grailsApplication.config.bie.baseUrl}",
            biocacheServiceUrl: "${alatag.getBiocacheAjaxUrl()}",
            collectoryUrl: "${grailsApplication.config.collectory.baseUrl}",
            skin: "${grailsApplication.config.skin.layout}",
            defaultListView: "${grailsApplication.config.defaultListView}",
            resourceName: "${grailsApplication.config.skin.orgNameLong}",
            facetLimit: "${grailsApplication.config.facets.limit?:50}",
            queryContext: "${grailsApplication.config.biocache.queryContext}",
            zoomOutsideScopedRegion: Boolean("${grailsApplication.config.map.zoomOutsideScopedRegion}"),
            hasMultimedia: ${hasImages?:'false'}, // will be either true or false
            locale: "${request.locale}",
            selectedDataResource: "${selectedDataResource}"
        };

        console.log("${alatag.getBiocacheAjaxUrl()}");

        google.load('maps','3.5',{ other_params: "sensor=false" });
        google.load("visualization", "1", {packages:["corechart"]});
    </script>
</head>

<body>
    %{-- Entête de la page résultat  --}%
    <div id="listHeader" class="row">
        <div class="col-xs-7 col-md-5">
            <br/>
            <h1><alatag:message code="search.heading.list" default="Recherche par occurrences : Résultat"/><a name="resultsTop">&nbsp;</a></h1>
        </div>
        <div class="col-xs-5 col-md-3"></div>
        <div id="searchBoxZ" class="col-xs-6 col-md-4 text-right">
            <form action="${g.createLink(controller: 'occurrences', action: 'search')}" id="solrSearchForm" class="">
                
                <div class="input-group">
                    <div id="advancedSearchLink"><a href="${g.createLink(uri: '/search')}#tab_advanceSearch" class="link"><g:message code="list.advancedsearchlink.navigator" default="Recherche avancée"/></a></div>
                    <div class="input-group">
                        <input type="text" id="taxaQuery" name="${searchQuery}" class="form-control" value="${params.list(searchQuery).join(' OR ')}" >
                        <span class="input-group-btn">
                            <button class="btn btn-default" type="submit" id="solrSubmit" >
                                <g:message code="list.advancedsearchlink.button.label" default="Recherche rapide"/>
                            </button>
                        </span>
                    </div> 
                </div>    
            </form>
        </div>
        <input type="hidden" id="userId" value="${userId}">
        <input type="hidden" id="userEmail" value="${userEmail}">
        <input type="hidden" id="lsid" value="${params.lsid}"/>
    </div>


    <g:if test="${errors}">
        <div class="searchInfo searchError">
            <h2 id="error-h2"><g:message code="list.01.error" default="Error"/></h2>
            <h4>${errors}</h4>
        </div>
    </g:if>

    %{-- Si pas de résultat  --}%
    <g:elseif test="${!sr || sr.totalRecords == 0}">
        <div class="searchInfo searchError">
            <g:if test="${queryDisplay =~ /lsid:/ && params.taxa}"> <!-- ${raw(queryDisplay)} -->
                <g:if test="${queryDisplay =~ /span/}">
                    <p><g:message code="list.02.p01" default="No records found for"/> <span class="queryDisplay">${raw(queryDisplay)}</span></p>
                </g:if>
                <g:else>
                    <p><g:message code="list.02.p02" default="No records found for"/> <span class="queryDisplay">${params.taxa}</span></p>
                </g:else>
                <p><g:message code="list.02.p03.01" default="Trying search for"/> <a href="?q=text:${params.taxa}"><g:message code="list.02.p03.02" default="text"/>:${params.taxa}</a></p>
            </g:if>
            <g:elseif test="${queryDisplay =~ /text:/ && queryDisplay =~ /\s+/ && !(queryDisplay =~ /\bOR\b/)}">
                <p><g:message code="list.03.p01" default="No records found for"/> <span class="queryDisplay">${raw(queryDisplay)}</span></p>
                <g:set var="queryTerms" value="${queryDisplay.split(" ")}"/>
                <p><g:message code="list.03.p02" default="Trying search for"/> <a href="?q=${queryTerms.join(" OR ")}">${queryTerms.join(" OR ")}</a></p>
            </g:elseif>
            <g:else>
                <p><g:message code="list.03.p03" default="No records found for"/> <span class="queryDisplay">${raw(queryDisplay)?:params.q}</span></p>
            </g:else>
        </div>
    </g:elseif>

    %{-- Si résultat --}%
    <g:else>
        <!--  first row (#searchInfoRow), contains customise facets button and number of results for query, etc.  -->
        <div class="row clearfix" id="searchInfoRow">
            <!-- facet column -->
            <div class="col-md-3">
                <div id="customiseFacetsButton" class="btn-group">
                     <a class="btn btn-small dropdown-toggle tooltips" href="#" data-toggle="dropdown" data-hasqtip="2" oldtitle="Personnaliser les filtres" title="" aria-describedby="qtip-2" id="perso-btn">
                        <i class="fa fa-cog"></i>
                        <g:message code="list.customisefacetsbutton.title" default="Personnaliser les filtres"/>
                        <span class="caret"></span>
                    </a>

                     %{-- Menu déroulant du bouton Personnalisé les filtres --}%
                    <div class="dropdown-menu" role="menu" style="width: 500%;"> <%--facetOptions--%>
                        <h4><g:message code="list.customisefacetsbutton.div01.title" default="Sélectionnez les catégories de filtre que vous souhaitez voir apparaître dans la colonne &quot;Affiner les résultats&quot;"/></h4>
                        <%-- <form:checkboxes path="facets" items="${defaultFacets}" itemValue="key" itemLabel="value" /> --%>
                        <div id="facetCheckboxes">
                        <g:message code="list.facetcheckboxes.label01" default="Sélectionner"/>: 
                            <a href="#" id="selectAll" class="link"><g:message code="list.facetcheckboxes.navigator01" default="Tous"/></a> |<a href="#" id="selectNone" class="link"><g:message code="list.facetcheckboxes.navigator02" default="Aucun"/></a>
                            &nbsp;&nbsp;
                            <button  id="updateFacetOptions" class="btn btn-default access-data"><g:message code="list.facetcheckboxes.button.updatefacetoptions" default="Actualiser"/></button>
                            &nbsp;&nbsp;
                            <g:set var="resetTitle" value="Restore default settings"/>
                            <button id="resetFacetOptions" class="btn btn-default access-data" title="${resetTitle}"><g:message code="list.facetcheckboxes.button.resetfacetoptions" default="Réinitialiser"/></button>
                            <br/>
                            %{--<div class="facetsColumn">--}%
                            <%-- iterate over the groupedFacets, checking the defaultFacets for each entry --%>
                            <g:set var="count" value="${0}"/>
                            <g:each var="group" in="${groupedFacets}">
                                <div class="facetsColumn">
                                    <div class="facetGroupName"><g:message code="facet.group.${group.key}" default="${group.key}"/></div>
                                    <g:each in="${group.value}" var="facetFromGroup">
                                        %{--<g:set var="facet" value="${defaultFacets.get(facetFromGroup)}"/>--}%
                                        <g:if test="${defaultFacets.containsKey(facetFromGroup)}">
                                            <g:set var="count" value="${count+1}"/>
                                            <input type="checkbox" name="facets" class="facetOpts" value="${facetFromGroup}"
                                                ${(defaultFacets.get(facetFromGroup)) ? 'checked=checked' : ''}><span class="facetName">&nbsp;<alatag:message code="facet.${facetFromGroup}"/></span><br>
                                        </g:if>
                                    </g:each>
                                </div>
                            </g:each>
                            %{--</div>--}%
                            <g:if test="${false && dynamicFacets}"><!-- INACTIVE - user not able to toggle display of custom fields for now -->
                                <div class="facetsColumn">
                                    <h4><g:message code="list.facetcheckboxes.div02.title" default="Custom facets"/></h4>
                                    <g:each var="facet" in="${dynamicFacets}">
                                        <input type="checkbox" name="facets" class="facetOpts" value="${facet.name}"
                                            ${(facet.name) ? 'checked="checked"' : ''}>&nbsp;${facet.displayName}<%--<alatag:formatDynamicFacetName fieldName="${facet.name}"/>--%><br>
                                    </g:each>
                                </div>
                            </g:if>
                        </div>
                        %{--<div class="clearfix"></div>--}%
                    </div>
                </div>
            </div><!-- /.span3 -->
            <!-- Results column -->
            <div class="col-md-9">
                <a name="map" class="jumpTo"></a><a name="list" class="jumpTo"></a>
                <g:if test="${false && flash.message}"><%-- OFF for now --%>
                    <div class="alert alert-info" style="margin-left: -30px;">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                        ${flash.message}
                    </div>
                </g:if>
                <div id="resultsReturned">
                        <span id="returnedText"><strong><g:formatNumber number="${sr.totalRecords}" format="#,###,###"/></strong> <g:message code="list.resultsretuened.span.returnedtext" default="results for"/></span>
                        <span class="queryDisplay"><strong>${raw(queryDisplay)}</strong></span>&nbsp;&nbsp;
                    %{--<g:set var="hasFq" value="${false}"/>--}%
                    <g:if test="${sr.activeFacetMap?.size() > 0 || params.wkt || params.radius}">
                        <div class="activeFilters">
                            <b><alatag:message code="search.filters.heading" default="Current filters"/></b>:&nbsp;
                            <g:each var="fq" in="${sr.activeFacetMap}">
                                <g:if test="${fq.key}">
                                    <g:set var="hasFq" value="${true}"/>
                                    <alatag:currentFilterItem item="${fq}" cssClass="btn btn-mini" addCloseBtn="${true}"/>
                                </g:if>
                            </g:each>
                            <g:if test="${params.wkt}"><%-- WKT spatial filter   --%>
                                <g:set var="spatialType" value="${params.wkt =~ /^\w+/}"/>
                                <a href="${alatag.getQueryStringForWktRemove()}" class="btn btn-mini tooltips" title="Click to remove this filter">Spatial filter: ${spatialType[0]}
                                    <span class="closeX">×</span>
                                </a>
                            </g:if>
                            <g:elseif test="${params.radius && params.lat && params.lon}">
                                <a href="${alatag.getQueryStringForRadiusRemove()}" class="btn btn-mini tooltips" title="Click to remove this filter">Spatial filter: CIRCLE
                                    <span class="closeX">×</span>
                                </a>
                            </g:elseif>
                            <g:if test="${sr.activeFacetMap?.size() > 1}">
                                <button class="btn  btn-mini activeFilter btn btn-default access-data" data-facet="all"
                                        title="Click to clear all filters"><span
                                        class="closeX"></span><g:message code="list.resultsretuened.button01" default="Clear all"/></button>
                            </g:if>
                        </div>
                    </g:if>
                    <%-- jQuery template used for taxon drop-downs --%>
                    <div class="btn-group hide" id="template">
                        <a class="btn btn-small" href="" id="taxa_" title="view species page" target="BIE"><g:message code="list.resultsretuened.navigator01" default="placeholder"/></a>
                        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown" title="click for more info on this query">
                            <span class="caret"></span>
                        </button>
                        <div class="dropdown-menu" aria-labelledby="taxa_">
                            <div class="taxaMenuContent">
                                <g:message code="list.resultsretuened.div01.des01" default="The search results include records for synonyms and child taxa of"/>
                                <b class="nameString"><g:message code="list.resultsretuened.div01.des02" default="placeholder"/></b> (<span class="speciesPageLink"><g:message code="list.resultsretuened.div01.des03" default="link placeholder"/></span>).

                                <form name="raw_taxon_search" class="rawTaxonSearch" action="${request.contextPath}/occurrences/search/taxa" method="POST">
                                    <div class="refineTaxaSearch">
                                        <g:message code="list.resultsretuened.form.des01" default="The result set contains records provided under the following names"/>:
                                        <input type="submit" class="btn btn-small rawTaxonSumbit"
                                               value="<g:message code="list.resultsretuened.form.button01" default="Refine search"/>" title="Restrict results to the selected names">
                                        <div class="rawTaxaList"><g:message code="list.resultsretuened.form.div01" default="placeholder taxa list"/></div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!-- /.span9 -->
        </div><!-- /#searchInfoRow -->
        <!--  Second row - facet column and results column -->
        <div class="row" id="content">
            <div class="col-md-3">
                <g:render template="facets" />
            </div>
            <g:set var="postFacets" value="${System.currentTimeMillis()}"/>
            <div id="content2" class="col-md-9">
                <g:if test="${grailsApplication.config.skin.useAlaSpatialPortal?.toBoolean()}">
                    <div id="alert" class="modal hide" tabindex="-1" role="dialog" aria-labelledby="alertLabel" aria-hidden="true">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                            <h3 id="myModalLabel"><g:message code="list.alert.title" default="Email alerts"/></h3>
                        </div>
                        <div class="modal-body">
                            <div class="">
                                <a href="#alertNewRecords" id="alertNewRecords" class="btn tooltips" data-method="createBiocacheNewRecordsAlert"
                                   title="Notify me when new records come online for this search"><g:message code="list.alert.navigator01" default="Get email alerts for new records"/> </a>
                            </div>
                            <br/>
                            <div class="">
                                <a href="#alertNewAnnotations" id="alertNewAnnotations" data-method="createBiocacheNewAnnotationsAlert"
                                   class="btn tooltips" title="Notify me when new annotations (corrections, comments, etc) come online for this search"><g:message code="list.alert.navigator02" default="Get email alerts for new annotations"/></a>
                            </div>
                            <p>&nbsp;</p>
                            <p><a href="http://alerts.ala.org.au/notification/myAlerts"><g:message code="list.alert.navigator03" default="View your current alerts"/></a></p>
                        </div>
                        <div class="modal-footer">
                            <button class="btn" data-dismiss="modal" aria-hidden="true"><g:message code="list.alert.button01" default="Close"/></button>
                            %{--<button class="btn btn-primary">Save changes</button>--}%
                        </div>
                    </div><!-- /#alerts -->
                </g:if>

                <g:render template="download"/>
                <div style="display:none">

                </div>


                <!-- Titre des onglets-->
                <div class="tabbable">
                    <ul class="nav nav-tabs" data-tabs="tabs">
                        <li class="active"><a id="t1" href="#recordsView" data-toggle="tab" class="link"><g:message code="list.link.t1" default="Enregistrements"/></a></li>
                        <li><a id="t2" href="#mapView" data-toggle="tab" class="link" ><g:message code="list.link.t2" default="Carte"/></a></li>
                        <li><a id="t3" href="#chartsView" data-toggle="tab" class="link"><g:message code="list.link.t3" default="Graphiques"/></a></li>
                        %{--<g:if test="${showSpeciesImages}">--}%
                            %{--<li><a id="t4" href="#speciesImages" data-toggle="tab"><g:message code="list.link.t4" default="Species images"/></a></li>--}%
                        %{--</g:if>--}%
                        <g:if test="${hasImages}">
                            <li><a id="t5" href="#recordImages" data-toggle="tab"><g:message code="list.link.t5" default="Record images"/></a></li>
                        </g:if>
                    </ul>
                </div>
                <div class="tab-content clearfix">
                    <!-- Entête  Enregistrement -->
                    <div class="tab-pane solrResults active" id="recordsView">
                        <div id="searchControls" class="row">
                            <!-- Entête de l'onglet Enregistrement -->
                            <div class="col-md-4">
                                <div id="downloads" class="btn btn-small">
                                    <a href="#download" role="button" data-toggle="modal" class="tooltips" title="Download all ${g.formatNumber(number:sr.totalRecords, format:"#,###,###")} records OR species checklist"><i class="fa fa-download"></i>&nbsp;&nbsp;<g:message code="list.downloads.navigator" default="Télécharger les données"/></a>
                                </div>
                                <g:if test="${grailsApplication.config.skin.useAlaSpatialPortal?.toBoolean()}">
                                    <div id="alerts" class="btn btn-small">
                                        <a href="#alert" role="button" data-toggle="modal" class="tooltips" title="Get email alerts for this search"><i class="fa fa-bell"></i>&nbsp;&nbsp;<g:message code="list.alerts.navigator" default="Alerts"/></a>
                                    </div>
                                </g:if>
                            </div>
                            <!-- Partie tri de l'onglet Enregistrement -->
                            <div id="sortWidgets" class="col-md-8">
                                <span class="hidden-phone"><g:message code="list.sortwidgets.span01" default="par"/> </span><g:message code="list.sortwidgets.span02" default="page"/> :
                                <select id="per-page" name="per-page" class="input-small">
                                    <g:set var="pageSizeVar" value="${params.pageSize?:params.max?:"20"}"/>
                                    <option value="10" <g:if test="${pageSizeVar == "10"}">selected</g:if>>10</option>
                                    <option value="20" <g:if test="${pageSizeVar == "20"}">selected</g:if>>20</option>
                                    <option value="50" <g:if test="${pageSizeVar == "50"}">selected</g:if>>50</option>
                                    <option value="100" <g:if test="${pageSizeVar == "100"}">selected</g:if>>100</option>
                                </select>&nbsp;
                                <g:set var="useDefault" value="${(!params.sort && !params.dir) ? true : false }"/>
                                <g:message code="list.sortwidgets.sort.label" default="trier par"/> :
                                <select id="sort" name="sort" class="input-small">
                                    <option value="score" <g:if test="${params.sort == 'score'}">selected</g:if>><g:message code="list.sortwidgets.sort.option01" default="Meilleure correspondance"/></option>
                                    <option value="taxon_name" <g:if test="${params.sort == 'taxon_name'}">selected</g:if>><g:message code="list.sortwidgets.sort.option02" default="Nom du taxon"/></option>
                                    <option value="common_name" <g:if test="${params.sort == 'common_name'}">selected</g:if>><g:message code="list.sortwidgets.sort.option03" default="Nom vernaculaire"/></option>
                                    <option value="occurrence_date" <g:if test="${params.sort == 'occurrence_date'}">selected</g:if>>${skin == 'avh' ? g.message(code:"list.sortwidgets.sort.option0401", default:"Date de la collecte") :  g.message(code:"list.sortwidgets.sort.option0402", default:"Date d'enregistrement")}</option>
                                    <g:if test="${skin != 'avh'}">
                                        <option value="record_type" <g:if test="${params.sort == 'record_type'}">selected</g:if>><g:message code="list.sortwidgets.sort.option05" default="Type d'enregistrement"/></option> 
                                    </g:if>
                                    <option value="first_loaded_date" <g:if test="${useDefault || params.sort == 'first_loaded_date'}">selected</g:if>><g:message code="list.sortwidgets.sort.option06" default="Ajouté le"/></option>
                                    <option value="last_assertion_date" <g:if test="${params.sort == 'last_assertion_date'}">selected</g:if>><g:message code="list.sortwidgets.sort.option07" default="Dernière annotation"/></option>
                                </select>&nbsp;
                                <g:message code="list.sortwidgets.dir.label" default="ordre"/>:
                                <select id="dir" name="dir" class="input-small">
                                    <option value="asc" <g:if test="${params.dir == 'asc'}">selected</g:if>><g:message code="list.sortwidgets.dir.option01" default="Croissant"/></option>
                                    <option value="desc" <g:if test="${useDefault || params.dir == 'desc'}">selected</g:if>><g:message code="list.sortwidgets.dir.option02" default="Descending"/></option>
                                </select>
                            </div><!-- sortWidget -->
                        </div><!-- searchControls -->

                        <div id="results">
                            <g:set var="startList" value="${System.currentTimeMillis()}"/>
                            <g:each var="occurrence" in="${sr.occurrences}">
                                <alatag:formatListRecordRow occurrence="${occurrence}" />
                            </g:each>
                        </div><!--close results-->
                        <g:if test="${params.benchmarks}">
                            <div style="color:#fff;">
                                <g:message code="list.recordsview.benchmarks.01" default="list render time"/> = ${(System.currentTimeMillis() - startList)} <g:message code="list.recordsview.benchmarks.02" default="ms"/><br>
                            </div>
                        </g:if>
                        <div id="searchNavBar" class="pagination">
                            <g:paginate total="${sr.totalRecords}" max="${sr.pageSize}" offset="${sr.startIndex}" params="${[taxa:params.taxa, q:params.q, fq:params.fq, wkt:params.wkt, lat:params.lat, lon:params.lon, radius:params.radius]}"/>
                        </div>
                    </div><!--end solrResults-->

                    <div id="mapView" class="tab-pane">
                        <g:render template="map"
                                  model="[mappingUrl:alatag.getBiocacheAjaxUrl(),
                                          searchString: searchString,
                                          queryDisplayString:queryDisplay,
                                          facets:sr.facetResults,
                                          defaultColourBy:grailsApplication.config.map.defaultFacetMapColourBy
                                  ]"
                        />

                        <div id='envLegend'></div>
                    </div><!-- end #mapwrapper -->
                    
                    <div id="chartsView" class="tab-pane">
                        <h2 class="admin-h2"><g:message code="public.sdr.content.label.stat" /></h2>
                        <div id="charts" class="row"></div>
                    </div><!-- end #chartsWrapper -->

                    %{--<g:if test="${showSpeciesImages}">--}%
                        %{--<div id="speciesImages" class="tab-pane">--}%
                            %{--<h3><g:message code="list.speciesimages.title" default="Representative images of species"/></h3>--}%
                            %{--<div id="speciesGalleryControls">--}%
                                %{--<g:message code="list.speciesgallerycontrols.label01" default="Filter by group"/>--}%
                                %{--<select id="speciesGroup">--}%
                                    %{--<option><g:message code="list.speciesgallerycontrols.speciesgroup.option01" default="no species groups loaded"/></option>--}%
                                %{--</select>--}%
                                %{--&nbsp;--}%
                                %{--<g:message code="list.speciesgallerycontrols.label02" default="Sort by"/>--}%
                                %{--<select id="speciesGallerySort">--}%
                                    %{--<option value="common"><g:message code="list.speciesgallerycontrols.speciesgallerysort.option01" default="Common name"/></option>--}%
                                    %{--<option value="taxa"><g:message code="list.speciesgallerycontrols.speciesgallerysort.option02" default="Scientific name"/></option>--}%
                                    %{--<option value="count"><g:message code="list.speciesgallerycontrols.speciesgallerysort.option03" default="Record count"/></option>--}%
                                %{--</select>--}%
                            %{--</div>--}%
                            %{--<div id="speciesGallery">[<g:message code="list.speciesgallerycontrols.speciesgallery" default="image gallery should appear here"/>]</div>--}%
                            %{--<div id="loadMoreSpecies" style="display:none;">--}%
                                %{--<button class="btn"><g:message code="list.speciesgallerycontrols.loadmorespecies.button" default="Show more images"/></button>--}%
                                %{--<img style="display:none;" src="${request.contextPath}/images/indicator.gif"/>--}%
                            %{--</div>--}%
                        %{--</div><!-- end #speciesWrapper -->--}%
                    %{--</g:if>--}%
                    <g:if test="${hasImages}">
                        <div id="recordImages" class="tab-pane">
                            <h3><g:message code="list.speciesgallerycontrols.recordimages.title" default="Images from occurrence records"/></h3>
                            <%--<p>(see also <a href="#tab_speciesImages">representative species images</a>)</p>--%>
                            <div id="imagesGrid">
                            <g:message code="list.speciesgallerycontrols.imagesgrid" default="loading images"/>...
                            </div>
                            <div id="loadMoreImages" style="display:none;">
                                <button class="btn"><g:message code="list.speciesgallerycontrols.loadmoreimages.button" default="Show more images"/>
                                    <img style="display:none;" src="${request.contextPath}/images/indicator.gif"/>
                                </button>
                            </div>
                            <%-- HTML template used by AJAX code --%>
                            <div class="imgConTmpl hide">
                                <div class="imgCon">
                                    <a class="cbLink" rel="thumbs" href="" id="thumb">
                                        <img src="" alt="${tc?.taxonConcept?.nameString} image thumbnail"/>
                                        <div class="meta brief"></div>
                                        <div class="meta detail hide"></div>
                                    </a>
                                </div>
                            </div>
                        </div><!-- end #imagesWrapper -->
                    </g:if>
                </div><!-- end .css-panes -->
                <form name="raw_taxon_search" class="rawTaxonSearch" id="rawTaxonSearchForm" action="${request.contextPath}/occurrences/search/taxa" method="POST">
                        <%-- taxon concept search drop-down div are put in here via Jquery --%>
                    <div style="display:none;" >
                    </div>
                </form>
            </div>
        </div>
    </g:else>
<g:if test="${params.benchmarks}">
    <g:set var="endPageTime" value="${System.currentTimeMillis()}"/>
    <div style="color:#ddd;">
        <g:message code="list.endpagetime01" default="post-facets time"/> = ${(endPageTime - postFacets)} ms<br>
        <g:message code="list.endpagetime02" default="page render time"/> = ${(endPageTime - startPageTime)} ms<br>
        <g:message code="list.endpagetime03" default="biocache-service GET time"/> = ${wsTime} ms<br>
        <g:message code="list.endpagetime04" default="controller processing time"/> = ${processingTime} ms<br>
        <g:message code="list.endpagetime05" default="total processing time"/> = ${(endPageTime - startPageTime) + processingTime} ms
    </div>
</g:if>

</body>
</html>