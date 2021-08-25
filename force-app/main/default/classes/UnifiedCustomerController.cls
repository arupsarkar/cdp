public with sharing class UnifiedCustomerController {
    public class CustomException extends Exception {} 
    public static String cdp_token {get; set;}
    public UnifiedCustomerController() {
        //GetCDPToken.cdp_token = getCDPToken();
    }
    public static String getCDPToken() {
        C360AuthController cdpAuth = new C360AuthController();        
        return cdpAuth.cdp_token;        
    }

    @AuraEnabled(cacheable=true)
    public static UnifiedIndividual[] getUnifiedIndividualSearchList(String searchParam, String searchParam2) {
        System.debug(LoggingLevel.DEBUG, '>>> Last Name ' + searchParam);
        System.debug(LoggingLevel.DEBUG, '>>> First Name ' + searchParam2);
        String urlCB = '';
        if(searchParam2.length() < 1) {
            // urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
            // 'SELECT+Id__c+,+FirstName__c+,+LastName__c+,+LoyaltyPoints__c+,+LoyaltyStatus__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+LIKE+\'' +searchParam+ '\'' +
            // '+LIMIT+100';
            urlCB = '{' + '"sql"' + ':' + '"select ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Interest__c, Channel_Preference__c, ' + 
            'ssot__GenderId__c, Category_Preference__c,ssot__BirthDate__c, ssot__InternalOrganizationId__c, ' + 
            'LoyaltyPoints__c, LoyaltyStatus__c ' + 
            'from UnifiedIndividual__dlm WHERE ssot__LastName__c = \'' + searchParam + '\' ' + 
            'LIMIT 10' + '"}';            
        }else {
            // urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
            // 'SELECT+Id__c+,+FirstName__c+,+LastName__c+,+LoyaltyPoints__c+,+LoyaltyStatus__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+LIKE+\'' +searchParam+ '\'' +
            // '+AND+FirstName__c+LIKE+\'' + searchParam2 + '\'' +
            // '+LIMIT+100';
            urlCB = '{' + '"sql"' + ':' + '"select ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Interest__c, Channel_Preference__c, ' + 
            'ssot__GenderId__c, Category_Preference__c,ssot__BirthDate__c, ssot__InternalOrganizationId__c, ' + 
            'LoyaltyPoints__c, LoyaltyStatus__c ' + 
            'from UnifiedIndividual__dlm WHERE ssot__LastName__c = \'' + searchParam + '\' ' + 
            'AND ssot__FirstName__c = \'' + searchParam2 + '\' ' +
            'LIMIT 10' + '"}';            
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
        // String urlCB = 'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
        //                 'SELECT+Id__c+,+FirstName__c+,+LastName__c+,+LoyaltyPoints__c+,+LoyaltyStatus__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+!=+null' +
        //                 '+LIMIT+5';
        String urlCB = '{' + '"sql"' + ':' + '"select ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Interest__c, Channel_Preference__c, ' + 
                        'ssot__GenderId__c, Category_Preference__c,ssot__BirthDate__c, ssot__InternalOrganizationId__c, ' + 
                        'LoyaltyPoints__c, LoyaltyStatus__c ' + 
                        'from UnifiedIndividual__dlm WHERE ssot__FirstName__c != \'' + '\'' + 
                        ' AND LoyaltyStatus__c != \'' + '\'' + ' LIMIT 10' + '"}';
        System.debug(LoggingLevel.DEBUG, urlCB);
        records = getResults(urlCB);
        if(!records.isEmpty()) {
            return records;
        }else {
            return null;
        }
        
    }


    private static UnifiedIndividual[] getResults(String urlCB) {
        System.debug(LoggingLevel.DEBUG, '>>> url ' + urlCB);
        //C360AuthController cdpAuth = new C360AuthController();
        cdp_token = getCDPToken();

        System.debug(LoggingLevel.DEBUG, '>>> token ' + cdp_token);                
        Set<String> unifiedIndividualIds = new Set<String>();
        List<UnifiedIndividual> records = new List<UnifiedIndividual>();  
        UnifiedIndividualParser unifiedInd;      
        Map<String, UnifiedIndividual> unifiedIndividualMap = new Map<String, UnifiedIndividual>();
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        //req.setMethod('GET');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + cdp_token);
        req.setBody(urlCB);
        //req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //req.setHeader('authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');
        

        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> raw output ' + res.getBody());  
        System.debug(LoggingLevel.DEBUG, '>>> status code ' + res.getStatusCode());  
        if(res.getStatusCode() == 500) {
            System.debug(LoggingLevel.ERROR, '>>> error ' + res.getStatus());  
            throw new CustomException(res.getBody());
        }
        Boolean errorFlag = false;
        try{
            String tempData1 = res.getBody().replaceAll('__c','');
            String tempData2 = tempData1.replaceAll('ssot__', '');
            unifiedInd = (UnifiedIndividualParser) JSON.deserialize(tempData2,UnifiedIndividualParser.class);
        }catch(exception ex) {
            errorFlag = true;
            System.debug(LoggingLevel.ERROR, '---> Error ' + ex.getMessage());
        }
        // if there is an error 
        if(errorFlag) {
            records = getSeedData();
            return records;
        }
              
        //UnifiedIndividualParser unifiedInd = UnifiedIndividualParser.parse(res.getBody());
        List<UnifiedIndividualParser.Data> inds = unifiedInd.Data;
        if(inds == null && inds.isEmpty()) {
            throw new CustomException(res.getBody());
        }

        System.debug(LoggingLevel.DEBUG, '---> inds.size() ' + inds.size());
        System.debug(LoggingLevel.DEBUG, '---> inds[0] ' + inds[0]);

        for(UnifiedIndividualParser.Data ind : inds) {

            System.debug(LoggingLevel.DEBUG, '>>> record : ' + 
                                                        ind.Id + ', ' + 
                                                        ind.FirstName + ',' +
                                                        ind.LastName + ',' +
                                                        ind.LoyaltyPoints + ',' +
                                                        ind.LoyaltyStatus);
            unifiedIndividualIds.add(ind.Id);
            // UnifiedIndividual record = new UnifiedIndividual();
            // record.Id = ind.Id;
            // record.FirstName = ind.FirstName;
            // record.LastName = ind.LastName;
            // unifiedIndividualMap.put(ind.Id, record);
            // records.add(record);
        }
        
        //get unified phone
        UnifiedContactPointPhoneController unifiedPhoneCtrl = new UnifiedContactPointPhoneController(unifiedIndividualIds, cdp_token);
        Map<String, UnifiedContactPointPhoneController.UnifiedIndividualPhone> unifiedIndividualPhoneMap = UnifiedContactPointPhoneController.getQueryResults();
        for(String key : unifiedIndividualPhoneMap.keySet()) {
            UnifiedContactPointPhoneController.UnifiedIndividualPhone phone = unifiedIndividualPhoneMap.get(key);
            System.debug(LoggingLevel.DEBUG, '>>> key ' + key + ', value ' + phone.TelephoneNumber);
        }

        //get unified email address
        UnifiedContactPointEmailController unifiedEmailCtrl = new UnifiedContactPointEmailController(unifiedIndividualIds, cdp_token);
        Map<String, UnifiedContactPointEmailController.UnifiedIndividualEmail> unifiedIndividualEmailMap = UnifiedContactPointEmailController.getQueryResults();

        for(UnifiedIndividualParser.Data ind : inds) {
            UnifiedIndividual record = new UnifiedIndividual();
            UnifiedContactPointPhoneController.UnifiedIndividualPhone phone = unifiedIndividualPhoneMap.get(ind.Id);
            UnifiedContactPointEmailController.UnifiedIndividualEmail email = unifiedIndividualEmailMap.get(ind.Id);
            record.Id = getResult(ind.Id);
            record.FirstName = getResult(ind.FirstName);
            record.LastName = getResult(ind.LastName);
            record.Telephone = phone != null ? getResult(phone.TelephoneNumber) : '';
            record.EmailAddress = email != null ? getResult(email.Email) : '';
            record.LoyaltyPoints = getResult(ind.LoyaltyPoints);
            record.LoyaltyStatus = getResult(ind.LoyaltyStatus);
            records.add(record);  
            System.debug(LoggingLevel.DEBUG, '---> record ' + record);          
        }


        System.debug(LoggingLevel.DEBUG, JSON.serializePretty(records));
        //return JSON.serialize(records);
        return records;
    }

    private static List<UnifiedIndividual> getSeedData() {
        List<UnifiedIndividual> records = new List<UnifiedIndividual>();
        UnifiedIndividual record1 = new UnifiedIndividual();
        
        record1.Id = 'e66d4b51-f21f-3875-8245-593c239e87c3';
        record1.FirstName = 'Jeffrey';
        record1.LastName = 'Lebowski';
        record1.EmailAddress = 'jlebowski@gmail.com';
        record1.LoyaltyPoints = '650';
        record1.LoyaltyStatus = 'Bronze';
        record1.Telephone = '646-100-5643';
        records.add(record1);

        UnifiedIndividual record2 = new UnifiedIndividual();
        record2.Id = 'badc497e-8d23-3065-a6b6-ff11ff10c02e';
        record2.FirstName = 'Jessica';
        record2.LastName = 'Brussard';
        record2.EmailAddress = 'jbrussard123@gmail.com';
        record2.LoyaltyPoints = '2130';
        record2.LoyaltyStatus = 'Platinum';
        record2.Telephone = '347-787-9098';

        
        records.add(record2);
        return records;
    }

    public class UnifiedIndividual {
        @AuraEnabled public String FirstName {get; set;}
        @AuraEnabled public String LastName {get; set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Telephone {get;set;}
        @AuraEnabled public String EmailAddress {get;set;}
        @AuraEnabled public String LoyaltyPoints {get;set;}
        @AuraEnabled public String LoyaltyStatus {get;set;}
    }

    private static String getResult(String data) {
        String result = '';
        if(String.isEmpty(data)) {
            return result;
        }else {
            result = data;
        }
        return result;
    }

}
