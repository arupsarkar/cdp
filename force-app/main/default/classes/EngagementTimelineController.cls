public with sharing class EngagementTimelineController {
    public EngagementTimelineController() {

    }
    @AuraEnabled
    public static List<C360_Engagement_Timeline__c> getWebRecords() {
        return[ SELECT Id, Name, EngagementChannel__c, EngagementDateTime__c, 
                    EngagementDevice__c, EngagementEvent__c, 
                    ProductSKU__c, UnifiedId__c, Domain__c, Referrer_Medium__c, Referrer_Campaign__c,
                    Referrer_Source__c, Product_Name__c, Content__c
                FROM C360_Engagement_Timeline__c 
                WHERE EngagementChannel__c = 'Web'
                LIMIT 5
        ];
    } 
    @AuraEnabled
    public static List<C360_Engagement_Timeline__c> getAppRecords(){
        try {
            return[ SELECT Id, Name, EngagementChannel__c, EngagementDateTime__c, 
                        EngagementDevice__c, EngagementEvent__c, 
                        ProductSKU__c, UnifiedId__c, Referrer_Medium__c, Referrer_Campaign__c,
                        Referrer_Source__c, Product_Name__c, Content__c
                    FROM C360_Engagement_Timeline__c 
                    WHERE EngagementChannel__c = 'App'
                    LIMIT 5];            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   

    @AuraEnabled
    public static List<C360_Engagement_Timeline__c> getEmailRecords(){
        try {
            return[ SELECT Id, Name, EngagementChannel__c, EngagementDateTime__c, 
                        EngagementDevice__c, EngagementEvent__c, 
                        ProductSKU__c, UnifiedId__c, SubjectLine__c
                    FROM C360_Engagement_Timeline__c 
                    WHERE EngagementChannel__c = 'Email'
                    LIMIT 5];            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }       
}
