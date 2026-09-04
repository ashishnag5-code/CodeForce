<aura:application extends="force:slds" access="global" implements="flexipage:availableForAllPageTypes">
    <ltng:require scripts="" afterScriptsLoaded="{!c.scriptsLoaded}" />
    <aura:attribute name="isLoaded" type="Boolean" default="false"/>
    <aura:attribute name="componentContainer" type="list"/>
    <aura:attribute name="componentName" type="String"/>
    <aura:attribute name="recordId" type="String"/>
    <aura:attribute name="integrationStatusRecordId" type="String"/>
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    <lightning:button variant="brand" label="Print" title="Print" onclick="{!c.scriptsLoaded}"></lightning:button>
    
    <aura:if isTrue="{!v.isLoaded}">
        <div class="printDoc">
            {!v.componentContainer}
        </div>
    </aura:if>
</aura:application>