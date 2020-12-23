public with sharing class UnifiedContactPointPhoneController {

    String queryCriteria = '';
    static Map<String, UnifiedIndividualPhone> unifiedIndividualPhoneMap = new Map<String, UnifiedIndividualPhone>();
    public UnifiedContactPointPhoneController(Set<String> queryParams) {
        queryCriteria = getQueryCriteria(queryParams);
        System.debug(LoggingLevel.DEBUG, '>>> before criteria ' + queryCriteria);
        String urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
                        'SELECT+Id__c+,+PartyId__c+,+TelephoneNumber__c' +
                        '+FROM+UnifiedContactPointPhone__dlm+WHERE+PartyId__c+IN+(' + queryCriteria + ')';  
        Map<String, UnifiedIndividualPhone> phoneMap = getResults(urlCB);
        unifiedIndividualPhoneMap.putAll(phoneMap);
    }

    public static Map<String, UnifiedIndividualPhone> getQueryResults() {
        return unifiedIndividualPhoneMap;
    }

    // /services/data/v49.0/query/?q=SELECT+Id__c+,+PartyId__c+,+TelephoneNumber__c+FROM+UnifiedContactPointPhone__dlm+WHERE+PartyId__c+IN+('310e3472-3b45-3548-9694-7845743cb3d9','e7ab2d5b-0c1c-3218-933c-9767400c31c6')+LIMIT+10    

    private string getQueryCriteria(Set<String> queryParams) {
        String result = '';
        integer counter = 0;
        for(String key : queryParams) {
            System.debug(LoggingLevel.DEBUG, '>>> Id ' + key);
            if(counter == 0) {
                result = '\'' + key + '\'';
            }else {
                result = result + ',' + '\'' + key + '\'';
            }
            counter++;
        }
        return result;
    }

    private Map<String, UnifiedIndividualPhone> getResults(String urlCB) {
        Map<String, UnifiedIndividualPhone> unifiedIndividualPhoneMap = new Map<String, UnifiedIndividualPhone>();
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint(urlCB);
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> raw output ' + res.getBody()); 
        UnifiedIndividualPhoneParser unifiedIndPhone = (UnifiedIndividualPhoneParser) JSON.deserialize(res.getBody().replaceAll('__c',''),UnifiedIndividualPhoneParser.class); 
        List<UnifiedIndividualPhoneParser.Records> phones = unifiedIndPhone.records;   
        for(UnifiedIndividualPhoneParser.Records phone : phones) {     
            System.debug(LoggingLevel.DEBUG, '>>> phone ' + phone.TelephoneNumber);
            UnifiedIndividualPhone indPhone = new UnifiedIndividualPhone();
            indPhone.Id = phone.Id;
            indPhone.PartyId = phone.PartyId;
            indPhone.TelephoneNumber = phone.TelephoneNumber;
            unifiedIndividualPhoneMap.put(phone.PartyId, indPhone);
        }

        return unifiedIndividualPhoneMap;
    }

    public class UnifiedIndividualPhone {
        public String Id {get; set;}
        public String PartyId {get; set;}
        public String TelephoneNumber {get;set;}
    }    
}
