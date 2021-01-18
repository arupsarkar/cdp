public with sharing class UnifiedContactIdentityKeysController {
    public UnifiedContactIdentityKeysController() {

    }
    @AuraEnabled(cacheable=true)
    public static IdentityKeysAttribute[] getUnifiedIdentityKeysSearchList(String searchParam) {
        Set<String> searchParams = new Set<String>();
        searchParams.add(searchParam);
        String queryCriteria = '';        
        string queryREST = 
                    'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
                    'SELECT+Id__c+,+PartyId__c+,+AddressLine1__c+,+AddressLine2__c+,+CityName__c' + 
                    '+,+StateProvinceName__c+,+CountryName__c+,+PostalCodeText__c' + 
                    '+FROM+UnifiedContactPointAddress__dlm' +
                    '+WHERE+PartyId__c+IN+(';

        queryCriteria = getQueryCriteria(searchParams);
        
        String urlCB =  queryREST + queryCriteria + ')+LIMIT+1'; 
        System.debug(LoggingLevel.DEBUG, '>>> final query ' + urlCB);
        List<IdentityKeysAttribute> records = new List<IdentityKeysAttribute>();  
        records = getResults(urlCB) ;
        return records;     

    }

    private static IdentityKeysAttribute[] getResults(String urlCB) {
        List<IdentityKeysAttribute> records = new List<IdentityKeysAttribute>();        
        Map<String, IdentityKeysAttribute> unifiedIndividualIdentityKeysMap = new Map<String, IdentityKeysAttribute>();
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setEndpoint(urlCB);
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> address output ' + res.getBody()); 
        UnifiedIndividualAddressParser unifiedIndKeysAttrs = (UnifiedIndividualAddressParser) JSON.deserialize(res.getBody().replaceAll('__c',''),UnifiedIndividualAddressParser.class); 
        List<UnifiedIndividualAddressParser.Records> keys = unifiedIndKeysAttrs.records;   
        for(UnifiedIndividualAddressParser.Records key : keys) {     
            System.debug(LoggingLevel.DEBUG, '>>> key ' + key.AddressLine1);
            IdentityKeysAttribute record = new IdentityKeysAttribute();
            record.Id = key.Id;
            record.AddressLine1 = key.AddressLine1;
            record.AddressLine2 = String.valueOf(key.AddressLine2);
            record.City = key.CityName;
            record.State = key.StateProvinceName;
            record.PostalCode = key.PostalCodeText;
            record.Country = String.valueOf(key.CountryName);
            records.add(record);
        }

        return records;
    }

    private static string getQueryCriteria(Set<String> queryParams) {
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

    public class IdentityKeysAttribute {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String AddressLine1 {get; set;}
        @AuraEnabled public String AddressLine2 {get; set;}
        @AuraEnabled public String City {get;set;}
        @AuraEnabled public String State {get;set;}
        @AuraEnabled public String Country {get;set;}
        @AuraEnabled public String PostalCode {get;set;}
    }    
}
