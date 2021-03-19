public with sharing class ProfileWrapper {
    public ProfileWrapper() {

    }

    @AuraEnabled
    public String unifiedId {get; set;}
    @AuraEnabled
    public String firstName {get; set;}
    @AuraEnabled
    public String lastName {get; set;}
    @AuraEnabled
    public String email {get; set;}
    @AuraEnabled
    public String phone {get; set;}
    @AuraEnabled
    public String points {get; set;}  
    @AuraEnabled
    public String status {get; set;}
}
