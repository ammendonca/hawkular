<?xml version="1.0" encoding="UTF-8"?>
<!--

    Copyright 2015-2016 Red Hat, Inc. and/or its affiliates
    and other contributors as indicated by the @author tags.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:ds="urn:jboss:domain:datasources:3.0" xmlns:ra="urn:jboss:domain:resource-adapters:3.0" xmlns:ejb3="urn:jboss:domain:ejb3:3.0"
  xmlns:logging="urn:jboss:domain:logging:3.0" xmlns:undertow="urn:jboss:domain:undertow:3.0" xmlns:tx="urn:jboss:domain:transactions:3.0"
  xmlns:messaging="urn:jboss:domain:messaging-activemq:1.0"
  version="2.0" exclude-result-prefixes="xalan ds ra ejb3 logging undertow tx messaging">

  <!-- will indicate if this is a "dev" build or "production" build -->
  <xsl:param name="kettle.build.type" />
  <xsl:param name="uuid.hawkular.accounts.backend" />

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" xalan:indent-amount="4" standalone="no" />
  <xsl:strip-space elements="*" />


  <xsl:template match="node()[name(.)='system-properties']">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <property>
        <xsl:attribute name="name">hawkular.metrics.waitForService</xsl:attribute>
        <xsl:attribute name="value">&#36;{hawkular.metrics.waitForService:true}</xsl:attribute>
      </property>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/*[local-name()='server']/*[local-name()='system-properties']/*[local-name()='property'][@name='keycloak.import']">
    <xsl:choose>
      <xsl:when test="$kettle.build.type='dev'">
        <property>
          <xsl:attribute name="name">keycloak.import</xsl:attribute>
          <xsl:attribute name="value">${keycloak.import:${jboss.home.dir}/standalone/configuration/hawkular-realm-for-dev.json}</xsl:attribute>
        </property>
      </xsl:when>
      <xsl:when test="$kettle.build.type='production'">
        <property>
          <xsl:attribute name="name">keycloak.import</xsl:attribute>
          <xsl:attribute name="value">${keycloak.import:${jboss.home.dir}/standalone/configuration/hawkular-realm.json}</xsl:attribute>
        </property>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          Unexpected value of &#36;kettle.build.type: '$kettle.build.type'. Expected 'dev' or 'production'
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="secure-deployment">
    <xsl:param name="deployment.name" />
    <xsl:param name="credential.secret" />
    <secure-deployment>
      <xsl:attribute name="name"><xsl:value-of select="$deployment.name"/></xsl:attribute>
      <realm>hawkular</realm>
      <resource>hawkular-accounts-backend</resource>
      <use-resource-role-mappings>true</use-resource-role-mappings>
      <enable-cors>true</enable-cors>
      <enable-basic-auth>true</enable-basic-auth>
      <credential name="secret"><xsl:value-of select="$credential.secret"/></credential>
    </secure-deployment>
  </xsl:template>

  <!-- //*[local-name()='secure-deployment'] is an xPath's 1.0 way of saying of xPath's 2.0 prefix-less selector //*:secure-deployment  -->
  <xsl:template match="//*[*[local-name()='secure-deployment']]">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-inventory-dist.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-metrics-component.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-command-gateway-war.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-alerts-rest.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-alerts-actions-email.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-wildfly-agent-download.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-rest-api.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>

      <!-- BTM INTEGRATION START -->
      <xsl:call-template name="secure-deployment">
        <xsl:with-param name="deployment.name" select="'hawkular-btm-server.war'" />
        <xsl:with-param name="credential.secret" select="*[local-name()='secure-deployment']/*[local-name()='credential' and @name='secret']/text()"/>
      </xsl:call-template>
      <!-- BTM INTEGRATION FINISH -->
    </xsl:copy>
  </xsl:template>

  <!-- Caches for Alerts -->
  <xsl:template match="node()[name(.)='cache-container'][1]">
    <xsl:copy>
      <xsl:copy-of select="node()|@*"/>
    </xsl:copy>
    <cache-container name="hawkular-alerts" default-cache="triggers" statistics-enabled="true">
      <local-cache name="partition"/>
      <local-cache name="triggers"/>
      <local-cache name="data"/>
    </cache-container>
  </xsl:template>

  <!-- add some logger categories -->
  <xsl:template name="loggers">
    <logger category="org.hawkular">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.accounts">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.accounts:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.agent">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.agent:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.alerts">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.alerts:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.cmdgw">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.cmdgw:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.component.availcreator">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.availcreator:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.component.pinger">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.pinger:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.inventory">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.inventory:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.inventory.rest.requests">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.inventory.rest.requests:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.inventory.ws">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.inventory.ws:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.metrics">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.metrics:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.hawkular.rest">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.rest:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>

    <!-- BTM INTEGRATION START -->
    <logger category="org.hawkular.btm">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.btm:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <!-- BTM INTEGRATION FINISH -->

    <logger category="com.datastax.driver">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.datastax.driver:INFO}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="liquibase">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.liquibase:WARN}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.jboss.as.ejb3">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.ejb3:WARN}</xsl:text></xsl:attribute>
      </level>
    </logger>
    <logger category="org.ocpsoft.rewrite">
      <level>
        <xsl:attribute name="name"><xsl:text disable-output-escaping="yes">${hawkular.log.rewrite:WARN}</xsl:text></xsl:attribute>
      </level>
    </logger>
  </xsl:template>

  <xsl:template match="node()[name(.)='periodic-rotating-file-handler']">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
    <xsl:call-template name="loggers"/>
  </xsl:template>

  <!-- Enable gzip compression when serving javascript and ccs -->
  <xsl:template match="undertow:subsystem/undertow:server/undertow:host">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <filter-ref name="gzipFilter" predicate="regex[pattern=&apos;(?:application/javascript|text/css|text/html|application/json)(;.*)?&apos;, value=%{{o,Content-Type}}, full-match=true]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="undertow:subsystem/undertow:filters">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <gzip name="gzipFilter" />
    </xsl:copy>
  </xsl:template>

  <!-- Enable Statistics for Undertow, TXs and Datasources -->
  <xsl:template match="undertow:subsystem">
    <xsl:copy>
      <xsl:attribute name="statistics-enabled">true</xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tx:subsystem">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <coordinator-environment statistics-enabled="true"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//*[local-name()='subsystem']/*[local-name()='datasources']/*[local-name()='datasource']">
    <xsl:copy>
      <xsl:attribute name="statistics-enabled">true</xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//messaging:subsystem/*[local-name()='server' and @name='default']">
    <xsl:copy>
      <xsl:attribute name="name">default</xsl:attribute>
      <statistics enabled="true"/>
      <xsl:apply-templates select="@*|node()"/>

      <jms-topic name="HawkularInventoryChanges" entries="java:/topic/HawkularInventoryChanges"/>
      <jms-topic name="HawkularAlertData" entries="java:/topic/HawkularAlertData"/>
      <jms-topic name="HawkularMetricData" entries="java:/topic/HawkularMetricData"/>
      <jms-queue name="HawkularAlertsPluginsQueue" entries="java:/queue/HawkularAlertsPluginsQueue"/>
      <jms-queue name="HawkularAlertsActionsResponseQueue" entries="java:/queue/HawkularAlertsActionsResponseQueue"/>
      <jms-topic name="HawkularAvailData" entries="java:/topic/HawkularAvailData"/>
      <jms-topic name="HawkularCommandEvent" entries="java:/topic/HawkularCommandEvent"/>
      <jms-topic name="HawkularAlertsActionsTopic" entries="java:/topic/HawkularAlertsActionsTopic"/>
      <jms-queue name="hawkular/metrics/gauges/new" entries="java:/queue/hawkular/metrics/gauges/new"/>
      <jms-queue name="hawkular/metrics/counters/new" entries="java:/queue/hawkular/metrics/counters/new"/>
      <jms-queue name="hawkular/metrics/availability/new" entries="java:/queue/hawkular/metrics/availability/new"/>

      <xsl:comment> Required by Hawkular BTM </xsl:comment>
      <jms-topic name="BusinessTransactions" entries="java:/BusinessTransactions"/>
      <jms-topic name="CommunicationDetails" entries="java:/CommunicationDetails"/>
      <jms-topic name="BTxnCompletionTimes" entries="java:/BTxnCompletionTimes"/>
      <jms-topic name="BTxnCompletionInformation" entries="java:/BTxnCompletionInformation"/>
      <jms-topic name="FragmentCompletionTimes" entries="java:/FragmentCompletionTimes"/>
      <jms-topic name="NodeDetails" entries="java:/NodeDetails"/>
      <jms-topic name="Notifications" entries="java:/Notifications"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node()[local-name()='cache-container'][last()]">

    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
    <cache-container name="btm" jndi-name="infinispan/BTM">
      <local-cache name="communicationdetails"/>
      <local-cache name="producerinfo"/>
    </cache-container>

  </xsl:template>

  <!-- A temporary fix to avoid WARN AMQ212053: CompletionListener/SendAcknowledgementHandler used with confirmationWindowSize=-1. ...
    This can be removed with the Accounts version comming after 2.0.11.Final  -->
  <xsl:template match="//*[local-name()='subsystem']/*[local-name()='server' and @name='default']/*[local-name()='connection-factory' and @name='InVmConnectionFactory']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:attribute name="confirmation-window-size">10024</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- copy everything else as-is -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
