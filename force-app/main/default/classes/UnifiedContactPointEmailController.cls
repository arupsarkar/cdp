public with sharing class UnifiedContactPointEmailController {
    String queryCriteria = '';
    static Map<String, UnifiedIndividualEmail> unifiedIndividualEmailMap = new Map<String, UnifiedIndividualEmail>();

    public UnifiedContactPointEmailController(Set<String> queryParams) {
        queryCriteria = getQueryCriteria(queryParams);
        System.debug(LoggingLevel.DEBUG, '>>> before criteria ' + queryCriteria);
        String urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
                        'SELECT+Id__c+,+PartyId__c+,+EmailAddress__c' +
                        '+FROM+UnifiedContactPointEmail__dlm+WHERE+PartyId__c+IN+(' + queryCriteria + ')';  
        Map<String, UnifiedIndividualEmail> emailMap = getResults(urlCB);
        unifiedIndividualEmailMap.putAll(emailMap);
    }

    public static Map<String, UnifiedIndividualEmail> getQueryResults() {
        return unifiedIndividualEmailMap;
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

    private Map<String, UnifiedIndividualEmail> getResults(String urlCB) {
        Map<String, UnifiedIndividualEmail> unifiedIndividualEmailMap = new Map<String, UnifiedIndividualEmail>();
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint(urlCB);
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> email output ' + res.getBody()); 
        UnifiedIndividualEmailParser unifiedIndEmail = (UnifiedIndividualEmailParser) JSON.deserialize(res.getBody().replaceAll('__c',''),UnifiedIndividualEmailParser.class); 
        List<UnifiedIndividualEmailParser.Records> emails = unifiedIndEmail.records;   
        for(UnifiedIndividualEmailParser.Records email : emails) {     
            System.debug(LoggingLevel.DEBUG, '>>> email ' + email.EmailAddress);
            UnifiedIndividualEmail indEmail = new UnifiedIndividualEmail();
            indEmail.Id = email.Id;
            indEmail.PartyId = email.PartyId;
            indEmail.Email = email.EmailAddress;
            unifiedIndividualEmailMap.put(email.PartyId, indEmail);
        }

        return unifiedIndividualEmailMap;
    }

    public class UnifiedIndividualEmail {
        public String Id {get; set;}
        public String PartyId {get; set;}
        public String Email {get;set;}
    }        
}
