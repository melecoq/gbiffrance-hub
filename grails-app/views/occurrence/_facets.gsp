
<div id="facetWell" class="well well-sm background-col">

    <g:set var="startTime" value="${System.currentTimeMillis()}"/>
    ${alatag.logMsg(msg:"Start of facets.gsp - " + startTime)}
    <h3 class="visible-xs">
        <a href="#" id="toggleFacetDisplay"><i class="icon-chevron-down" id="facetIcon"></i>
            <alatag:message code="search.facets.heading" default="Affiner vos résultats"/></a>
    </h3>
    <div class="sidebar hidden-sm">
        <h3 class="hidden-sm" id="admin-h2"><alatag:message code="search.facets.heading" default="Affiner vos résultats"/></h3>
    </div>
    <div class="sidebar hidden-sm clear-both">
        <g:if test="${sr.query}">
            <g:set var="queryStr" value="${params.q ? params.q : searchRequestParams.q}"/>
            <g:set var="paramList" value=""/>
            <g:set var="queryParam" value="${sr.urlParameters.stripIndent(1)}" />
        </g:if>
        <g:if test="${sr.activeFacetMap}">
            <div id="currentFilter">
                <h4><span class="FieldName"><alatag:message code="search.filters.heading" default="Filtres sélectionnés"/></span></h4>
                <div class="subnavlist">
                    <ul id="refinedFacets">
                        <g:each var="item" in="${sr.activeFacetMap}">
                            <li><alatag:currentFilterItem item="${item}" addCheckBox="${true}"/></li>
                        </g:each>
                        <g:if test="${sr.activeFacetMap?.size() > 1}">
                            <li><a href="#" class="activeFilter" data-facet="all" title="Click to clear all filters">
                                <span class="closeX" style="margin-left:7px;">&gt;&nbsp;</span><g:message code="facets.currentfilter.link" default="Clear all"/></a>
                            </li>
                        </g:if>
                    </ul>
                </div>
            </div>
        </g:if>
        ${alatag.logMsg(msg:"Before grouped facets facets.gsp")}
        <g:set var="facetMax" value="${10}"/><g:set var="i" value="${1}"/>
        <g:if test="${dynamicFacets?.size() > 0}">
            <div class="facetGroupName" id="heading_dynamicFacets">
                <a href="#" class="showHideFacetGroup" data-name="dynamicFacets"><span class="caret right-caret"></span> ${alatag.message(code:"facets.dynamic.heading", default:"Custom fields")}</a>
            </div>
            <div class="facetsGroup hide" id="group_dynamicFacets">
                <g:each in="${dynamicFacets}" var="df">
                    %{--${df.name}<br>--}%
                    <g:set var="facetResult" value="${groupedFacetsMap.get(df.name)}"/>
                    %{--<g:if test="${facetResult}">facetResult = ${facetResult}<br></g:if>--}%
                    <g:if test="${facetResult && facetResult.fieldResult.length() >= 1 && facetResult.fieldResult[0].count != sr.totalRecords && ! sr.activeFacetMap?.containsKey(facetResult.fieldName ) }">
                        <g:set var="fieldDisplayName" value="${df.displayName}"/>
                        <h4><span class="FieldName">${fieldDisplayName?:alatag.formatDynamicFacetName(fieldName:facetResult.fieldName)}</span></h4>
                        <div class="subnavlist nano" style="clear:left">
                            <alatag:facetLinkList facetResult="${facetResult}" queryParam="${queryParam}" fieldDisplayName="${fieldDisplayName}"/>
                        </div>
                        %{--<div class="fadeout"></div>--}%
                        <g:if test="${facetResult.fieldResult.length() > 0}">
                            <div class="showHide">
                                <a href="#multipleFacets" class="multipleFacetsLink" id="multi-${facetResult.fieldName}" role="button" data-toggle="modal" data-displayname="${fieldDisplayName}"
                                   title="See more options or refine with multiple values"><i class="icon-hand-right"></i> <g:message code="facets.groupdynamicfacets.link" default="choose more"/>...</a>
                            </div>
                        </g:if>
                    </g:if>
                </g:each>
            </div>
        </g:if>

        <g:each var="group" in="${groupedFacets}">
            <g:set var="keyCamelCase" value="${group.key.replaceAll(/\s+/,'')}"/>
            <div class="facetGroupName" id="heading_${keyCamelCase}">
                <a href="#" class="showHideFacetGroup" data-name="${keyCamelCase}">
                    <span class="caret black "></span>
                    <g:message code="facet.group.${group.key}" default="${group.key}"/>
                </a>
            </div>
            <div class="facetsGroup" id="group_${keyCamelCase}">
                <g:set var="firstGroup" value="${false}"/>
                <g:each in="${group.value}" var="facetFromGroup">
                    <%--  Do a lookup on groupedFacetsMap for the current facet --%>
                    <g:set var="facetResult" value="${groupedFacetsMap.get(facetFromGroup)}"/>
                   <%--  Tests for when to display a facet --%>
                    <g:if test="${facetResult && facetResult.fieldResult.length() >= 1 && facetResult.fieldResult[0].count != sr.totalRecords && ! sr.activeFacetMap?.containsKey(facetResult.fieldName ) }">
                        <g:set var="fieldDisplayName" value="${alatag.formatDynamicFacetName(fieldName:"${facetResult.fieldName}")}"/>
                        <h4><span class="FieldName">${fieldDisplayName?:facetResult.fieldName}</span></h4>
                        <div class="subnavlist nano clear-left">
                            <alatag:facetLinkList facetResult="${facetResult}" queryParam="${queryParam}"/>
                        </div>
                        %{--<div class="fadeout"></div>--}%
                        <g:if test="${facetResult.fieldResult.length() > 0}">
                            <div class="showHide">
                                <a href="#multipleFacets" class="multipleFacetsLink" id="multi-${facetResult.fieldName}" role="button" data-toggle="modal" data-displayname="${fieldDisplayName}"
                                   title="Voir plus d'options ou affiner avec plusieurs valeurs"><i class=" glyphicon glyphicon-hand-right"></i> <g:message code="facets.facetfromgroup.link" default="Plus de choix"/>...</a>
                            </div>
                        </g:if>
                    </g:if>
                </g:each>
            </div>
        </g:each>
        ${alatag.logMsg(msg:"After grouped facets facets.gsp")}
    </div>
</div><!--end facets-->
<!-- modal popup for "choose more" link -->
<div id="multipleFacets" class="modal" tabindex="-1" role="dialog" aria-labelledby="multipleFacetsLabel" aria-hidden="true"><!-- BS modal div -->
    <div class="modal-content">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <h3 id="multipleFacetsLabel"><g:message code="facets.multiplefacets.title" default="Affiner votre recherche"/></h3>
        <div id="dynamic" class="tableContainer">
            <form name="facetRefineForm" id="facetRefineForm" method="GET" action="/occurrences/search/facets">
                <table class="table table-bordered table-condensed table-striped scrollTable" id="fullFacets">
                    <thead class="fixedHeader">
                        <tr class="tableHead">
                            <th>&nbsp;</th>
                            <th id="indexCol" width="80%"><a href="#index" class="fsort" data-sort="index" data-foffset="0"></a></th>
                            <th style="border-right-style: none;text-align: right;"><a href="#count" class="fsort" data-sort="count" data-foffset="0" title="Sort by record count"><g:message code="facets.multiplefacets.tableth01" default="Count"/></a></th>
                        </tr>
                    </thead>
                    <tbody class="scrollContent">
                        <tr class="hide">
                            <td><input type="checkbox" name="fqs" class="fqs" value=""></td>
                            <td><a href=""></a></td>
                            <td style="text-align: right; border-right-style: none;"></td>
                        </tr>
                        <tr id="spinnerRow">
                            <td colspan="3" style="text-align: center;"><g:message code="facets.multiplefacets.tabletr01td01" default="loading data"/>... <g:img plugin="biocache-hubs" dir="images" file="spinner.gif" id="spinner2" class="spinner" alt="spinner icon"/></td>
                        </tr>
                    </tbody>
                </table>
            </form>
        </div>
        <div id='submitFacets' class="" style="text-align: left;">
            <div class="btn-group">
                <button type='submit' class='submit btn btn-small' id="include"><g:message code="facets.includeSelected.button" default="INCLURE les éléments sélectionnés"/></button>
                <button class="btn btn-small dropdown-toggle" data-toggle="dropdown">
                    <span class="caret black"></span>
                </button>
                <ul class="dropdown-menu">
                    <!-- dropdown menu links -->
                    <li>
                        <a href="#" class="wildcard" id="includeAll"><g:message code="facets.submitfacets.li01" default="INCLURE toutes les valeurs (y compris les caractères de remplacement)"/></a>
                    </li>
                </ul>
            </div>
            &nbsp;
            <div class="btn-group">
                <button type='submit' class='submit btn btn-small' id="exclude" ><g:message code="facets.excludeSelected.button" default="EXCLURE les éléments sélectionnés"/></button>
                <button class="btn btn-small dropdown-toggle" data-toggle="dropdown">
                    <span class="caret black"></span>
                </button>
                <ul class="dropdown-menu">
                    <!-- dropdown menu links -->
                    <li>
                        <a href="#" class="wildcard" id="excludeAll"><g:message code="facets.submitfacets.li02" default="EXCLURE toutes les valeurs (sauf les caractères de remplacement)"/></a>
                    </li>
                </ul>
            </div>
            &nbsp;
            <a href="#" id="downloadFacet" class="btn btn-sm" title="${g.message(code:'facets.downloadfacets.button', default:'Télécharger cette liste')}"><i class="glyphicon glyphicon-save" title="${g.message(code:'facets.downloadfacets.button', default:'Download this list')}"></i> <span class="hide"><g:message code="facets.downloadfacets.button" default="Download"/></span></a>
            <button class="btn btn-small" data-dismiss="modal" aria-hidden="true" style="float:right;"><g:message code="facets.submitfacets.button" default="Fermer"/></button>
        </div>
    </div>
</div>
<script type="text/javascript">
    var dynamicFacets = new Array();
    <g:each in="${dynamicFacets}" var="dynamicFacet">
        dynamicFacets.push('${dynamicFacet.name}');
    </g:each>
</script>
<g:if test="${params.benchmarks}">
    <g:set var="endTime" value="${System.currentTimeMillis()}"/>
    ${alatag.logMsg(msg:"End of facets.gsp - " + endTime + " => " + (endTime - startTime))}
    <div style="color:#ddd;">
        <g:message code="facets.endtime.l" default="facets render time"/> = ${(endTime - startTime)} <g:message code="facets.endtime.r" default="ms"/>
    </div>
</g:if>
