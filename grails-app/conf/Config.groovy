// locations to search for config files that get merged into the main config;
// config files can be ConfigSlurper scripts, Java properties files, or classes
// in the classpath in ConfigSlurper format

// grails.config.locations = [ "classpath:${appName}-config.properties",
//                             "classpath:${appName}-config.groovy",
//                             "file:${userHome}/.grails/${appName}-config.properties",
//                             "file:${userHome}/.grails/${appName}-config.groovy"]

// if (System.properties["${appName}.config.location"]) {
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
// }

grails.project.groupId = "" // change this to alter the default package name and Maven publishing destination

default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
if (new File(default_config).exists()) {
    println "[${appName}] Including default configuration file: " + default_config;
    grails.config.locations.add "file:" + default_config
} else {
    println "[${appName}] No external configuration file defined."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"
println "default_config = ${default_config}"

/******************************************************************************\
 *  SKINNING
\******************************************************************************/
skin.layout = 'alf'
skin.orgNameLong = "Atlas of Living France"
skin.orgNameShort = "Occurrences"
// whether crumb trail should include a home link that is external to this webabpp - ala.baseUrl is used if true
skin.includeBaseUrl = true
//skin.headerUrl = "classpath:resources/generic-header.jsp" // can be external URL
//skin.footerUrl = "classpath:resources/generic-footer.jsp" // can be external URL
skin.fluidLayout = true // true or false
skin.useAlaBie = false
chartsBgColour = "#FFFFFF"
// 3rd part WMS layer to show on maps
map.overlay.url = ""
map.overlay.name = ""
biocache.baseUrl="http://recherche-ws.gbif.fr"
gbif.baseUrl="http://api.gbif.org/v1/"
bieService.baseUrl = "http://species-ws.als.scot"
/******************************************************************************\
 *  MISC
\******************************************************************************/


// The ACCEPT header will not be used for content negotiation for user agents containing the following strings (defaults to the 4 major rendering engines)
grails.mime.disable.accept.header.userAgents = ['Gecko', 'WebKit', 'Presto', 'Trident']
grails.mime.types = [ // the first one is the default format
    all:           '*/*', // 'all' maps to '*' or the first available format in withFormat
    atom:          'application/atom+xml',
    css:           'text/css',
    csv:           'text/csv',
    form:          'application/x-www-form-urlencoded',
    html:          ['text/html','application/xhtml+xml'],
    js:            'text/javascript',
    json:          ['application/json', 'text/json'],
    multipartForm: 'multipart/form-data',
    rss:           'application/rss+xml',
    text:          'text/plain',
    hal:           ['application/hal+json','application/hal+xml'],
    xml:           ['text/xml', 'application/xml']
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*', '/bootstrap3/fonts/*', '/bootstrap3/css/*', '/bootstrap3/js/*', '/bootstrap3/fonts/*']
grails.resources.adhoc.includes = ['/images/*', '/css/*', '/js/*', '/plugins/*', '/bootstrap3/fonts/**', '/bootstrap3/css/**', '/bootstrap3/js/**', '/bootstrap3/fonts/**']

// Legacy setting for codec used to encode data with ${}
grails.views.default.codec = "html"

// The default scope for controllers. May be prototype, session or singleton.
// If unspecified, controllers are prototype scoped.
grails.controllers.defaultScope = 'singleton'

// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'html' // escapes values inside ${}
                scriptlet = 'html' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        filteringCodecForContentType {
            //'text/html' = 'html'
        }
    }
}
 
grails.converters.encoding = "UTF-8"
grails.views.gsp.encoding = "UTF-8"
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// configure auto-caching of queries by default (if false you can cache individual queries with 'cache: true')
grails.hibernate.cache.queries = false

config.security.cas.bypass=true

environments {
    development {
        grails.serverURL = 'http://localhost:8080/' + appName
        serverName='http://localhost:8080/'
//        security.cas.appServerName = serverName
//        security.cas.contextPath = "/${appName}"
        grails.resources.debug = true // cache & resources plugins
    }
    test {
//        grails.serverURL = 'http://localhost:8080/' + appName
//        serverName='http://localhost:8080/'
          grails.serverURL = 'http://recherche.gbif.fr/'
          serverName='http://recherche.gbif.fr/'
//        security.cas.appServerName = serverName
        //security.cas.contextPath = "/${appName}"
    }
    production {
//        grails.serverURL = 'http://biocache.ala.org.au'
//        serverName='http://biocache.ala.org.au'
//        security.cas.appServerName = serverName
    }
}

// log4j configuration
log4j = {
    // Example of changing the log pattern for the default console appender:
    //
    appenders {
        environments {
            production {
//                rollingFile name: "tomcatLog", maxFileSize: 102400000, file: "/var/log/tomcat6/${appName}.log", threshold: org.apache.log4j.Level.ERROR, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
//                'null' name: "stacktrace"
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n"), threshold: org.apache.log4j.Level.WARN
            }
            development {
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n"), threshold: org.apache.log4j.Level.DEBUG
            }
            test {
//                rollingFile name: "tomcatLog", maxFileSize: 102400000, file: "/tmp/${appName}-test.log", threshold: org.apache.log4j.Level.DEBUG, layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n")
//                'null' name: "stacktrace"
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}]  %m%n"), threshold: org.apache.log4j.Level.INFO
            }
        }
    }

    root {
        info 'stdout'
    }

    error  'org.codehaus.groovy.grails.web.servlet',        // controllers
           'org.codehaus.groovy.grails.web.pages',          // GSP
           'org.codehaus.groovy.grails.web.sitemesh',       // layouts
           'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
           'org.codehaus.groovy.grails.web.mapping',        // URL mapping
           'org.codehaus.groovy.grails.commons',            // core / classloading
           'org.codehaus.groovy.grails.plugins',            // plugins
           'org.codehaus.groovy.grails.orm.hibernate',      // hibernate integration
           'org.springframework',
           'org.hibernate',
           'net.sf.ehcache.hibernate'
    info   'grails.app'
    debug  'grails.app.controllers',
           'grails.app.services',
           //'grails.app.taglib',
           'grails.web.pages',
            //'grails.app',
            'au.org.ala.cas',
            'au.org.ala.biocache.hubs',
            'au.org.ala.biocache.hubs.OccurrenceTagLib'
}

exploreYourArea.lat = "2.4"
exploreYourArea.lng = "46.6"
exploreYourArea.location = "Saulzais-le-Potier"
map.mapbox.id = "nickdos.kf2g7gpb" // http://mapbox.com/ Registered by Nick - free to use so anyone can create a new one and add it here
map.mapbox.token = "pk.eyJ1Ijoibmlja2RvcyIsImEiOiJ2V2dBdEg0In0.Ep2VyMOaOUnOwN1ZVa9uyQ"
collections.baseUrl="http://metadonnee.gbif.fr"
collectory.baseUrl="http://metadonnee.gbif.fr"



facets.includeDynamicFacets = "false" // sandbox
facets.limit = "100"
facets.customOrder = ""
facets.exclude = "dataHubUid,year,day,modified,left,right,provenance,taxonID,preferredFlag,outlierForLayers,speciesGroups,associatedMedia,images,userQualityAssertion,speciesHabitats,duplicationType,taxonomicIssues,subspeciesID,nameMatchMetric,sounds"
facets.hide = "genus,order,class,phylum,kingdom,raw_taxon_name,rank,interaction,raw_state_conservation,biogeographic_region,year,institution_uid,collection_uid"
facets.include = "establishment_means,user_assertions,assertion_user_id,name_match_metric,duplicate_type,alau_user_id,raw_datum,raw_sex,life_stage,elevation_d_rng,identified_by,species_subgroup,cl1048"
facets.cached = "collection_uid,institution_uid,data_resource_uid,data_provider_uid,type_status,basis_of_record,species_group,loan_destination,establishment_means,state_conservation,state,cl1048,cl21,cl966,country,cl959"
