public with sharing class EngagementTimelineController {
    public EngagementTimelineController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<C360_Engagement_Timeline__c> getEngagementRecords() {
        return[ SELECT Id, Name, EngagementChannel__c, EngagementDateTime__c, 
                    EngagementDevice__c, EngagementEvent__c, 
                    ProductSKU__c, UnifiedId__c
                FROM C360_Engagement_Timeline__c LIMIT 5
        ];
    }    
}
