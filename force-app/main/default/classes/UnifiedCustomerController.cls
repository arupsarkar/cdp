public with sharing class UnifiedCustomerController {
    public UnifiedCustomerController() {

    }

    @AuraEnabled(cacheable=true)
    public static UnifiedIndividual[] getUnifiedIndividualSearchList(String searchParam, String searchParam2) {
        System.debug(LoggingLevel.DEBUG, '>>> Last Name ' + searchParam);
        System.debug(LoggingLevel.DEBUG, '>>> First Name ' + searchParam2);
        String urlCB = '';
        if(searchParam2.length() < 1) {
            urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
            'SELECT+Id__c+,+FirstName__c+,+LastName__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+LIKE+\'' +searchParam+ '\'' +
            '+LIMIT+100';
        }else {
            urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
            'SELECT+Id__c+,+FirstName__c+,+LastName__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+LIKE+\'' +searchParam+ '\'' +
            '+AND+FirstName__c+LIKE+\'' + searchParam2 + '\'' +
            '+LIMIT+100';
        }
        List<UnifiedIndividual> records = new List<UnifiedIndividual>();
        records = getResults(urlCB);
        return records;
    }

    @AuraEnabled(cacheable=true)
    public static UnifiedIndividual[] getUnifiedIndividualList() {


        List<UnifiedIndividual> records = new List<UnifiedIndividual>();
        // This can be called from server side and will work fine
        // but will not work from LWC
        // String url = 'https://rcgcdp228.my.salesforce.com/services/data/v50.0/query/?q=' +
        //                 'SELECT+Id__c+,+FirstName__c+,+LastName__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+!=+null' +
        //                 '+LIMIT+10';

        // 1. Create a connected app
        // 2. Create a Auth Provider
        // 3. Create a named credential
        // Reference https://eltoroit.herokuapp.com/Blog.app?page=ETLC_APIsFromApex
        String urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
                        'SELECT+Id__c+,+FirstName__c+,+LastName__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+!=+null' +
                        '+LIMIT+5';
        records = getResults(urlCB);
        if(!records.isEmpty()) {
            return records;
        }else {
            return null;
        }
        
    }


    private static UnifiedIndividual[] getResults(String urlCB) {
        System.debug(LoggingLevel.DEBUG, '>>> url ' + urlCB);
        Set<String> unifiedIndividualIds = new Set<String>();
        Map<String, UnifiedIndividual> unifiedIndividualMap = new Map<String, UnifiedIndividual>();
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //req.setHeader('authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setEndpoint(urlCB);
        

        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> raw output ' + res.getBody());  
        UnifiedIndividualParser unifiedInd = (UnifiedIndividualParser) JSON.deserialize(res.getBody().replaceAll('__c',''),UnifiedIndividualParser.class);      
        //UnifiedIndividualParser unifiedInd = UnifiedIndividualParser.parse(res.getBody());
        List<UnifiedIndividualParser.Records> inds = unifiedInd.records;

        List<UnifiedIndividual> records = new List<UnifiedIndividual>();

        for(UnifiedIndividualParser.Records ind : inds) {

            System.debug(LoggingLevel.DEBUG, '>>> record : ' + 
                                                        ind.Id + ', ' + 
                                                        ind.FirstName + ',' +
                                                        ind.LastName);
            unifiedIndividualIds.add(ind.Id);
            // UnifiedIndividual record = new UnifiedIndividual();
            // record.Id = ind.Id;
            // record.FirstName = ind.FirstName;
            // record.LastName = ind.LastName;
            // unifiedIndividualMap.put(ind.Id, record);
            // records.add(record);
        }
        
        //get unified phone
        UnifiedContactPointPhoneController unifiedPhoneCtrl = new UnifiedContactPointPhoneController(unifiedIndividualIds);
        Map<String, UnifiedContactPointPhoneController.UnifiedIndividualPhone> unifiedIndividualPhoneMap = UnifiedContactPointPhoneController.getQueryResults();
        for(String key : unifiedIndividualPhoneMap.keySet()) {
            UnifiedContactPointPhoneController.UnifiedIndividualPhone phone = unifiedIndividualPhoneMap.get(key);
            System.debug(LoggingLevel.DEBUG, '>>> key ' + key + ', value ' + phone.TelephoneNumber);
        }

        //get unified email address
        UnifiedContactPointEmailController unifiedEmailCtrl = new UnifiedContactPointEmailController(unifiedIndividualIds);
        Map<String, UnifiedContactPointEmailController.UnifiedIndividualEmail> unifiedIndividualEmailMap = UnifiedContactPointEmailController.getQueryResults();

        for(UnifiedIndividualParser.Records ind : inds) {
            UnifiedIndividual record = new UnifiedIndividual();
            UnifiedContactPointPhoneController.UnifiedIndividualPhone phone = unifiedIndividualPhoneMap.get(ind.Id);
            UnifiedContactPointEmailController.UnifiedIndividualEmail email = unifiedIndividualEmailMap.get(ind.Id);
            record.Id = ind.Id;
            record.FirstName = ind.FirstName;
            record.LastName = ind.LastName;
            record.Telephone = phone.TelephoneNumber;
            record.EmailAddress = email.Email;
            records.add(record);            
        }


        System.debug(LoggingLevel.DEBUG, JSON.serializePretty(records));
        //return JSON.serialize(records);
        return records;
    }

    public class UnifiedIndividual {
        @AuraEnabled public String FirstName {get; set;}
        @AuraEnabled public String LastName {get; set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Telephone {get;set;}
        @AuraEnabled public String EmailAddress {get;set;}
    }
}
