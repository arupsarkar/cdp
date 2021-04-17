public inherited sharing class SegmentMembershipController {
    public SegmentMembershipController() {

    }
    @AuraEnabled
    public static List<C360_Segment_Membership__c> getSegmentMemberships() {
        return[ SELECT Id, Segment_Name__c
                FROM C360_Segment_Membership__c
        ];
    }    
}
