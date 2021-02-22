public with sharing class UnifiedContactIdentityKeysController {
    
    public static String cdp_token {get; set;}
    public static String queryCriteria {get; set;}
    public static String unifiedIndividualId {get; set;}
    public UnifiedContactIdentityKeysController() {}

    @AuraEnabled
    public static IdentityKeysAttribute[] getUnifiedIdentityKeysSearchList(String searchParam) {
        unifiedIndividualId = searchParam;
        Set<String> searchParams = new Set<String>();
        searchParams.add(searchParam);
        // String queryCriteria = '';        
        // string queryREST = 
        //             'callout:UnifiedIndividual/services/data/v50.0/query/?q=' +
        //             'SELECT+Id__c+,+PartyId__c+,+AddressLine1__c+,+AddressLine2__c+,+CityName__c' + 
        //             '+,+StateProvinceName__c+,+CountryName__c+,+PostalCodeText__c' + 
        //             '+FROM+UnifiedContactPointAddress__dlm' +
        //             '+WHERE+PartyId__c+IN+(';

        queryCriteria = getQueryCriteria(searchParams);
        String urlCB = '{' + '"sql"' + ':' + '"SELECT Id__c, PartyId__c, AddressLine1__c, AddressLine2__c, ' + 
            'CityName__c, StateProvinceName__c, CountryName__c, PostalCodeText__c ' +
        'FROM UnifiedContactPointAddress__dlm WHERE PartyId__c IN (' + queryCriteria + ') LIMIT 1"' + 
        '}';
        
        // String urlCB =  queryREST + queryCriteria + ')+LIMIT+1'; 
        System.debug(LoggingLevel.DEBUG, '>>> final query ' + urlCB);
        List<IdentityKeysAttribute> records = new List<IdentityKeysAttribute>();  
        records = getResults(urlCB) ;
        // call LTV
        LTVController();
        SalesOrderController();
        return records;     

    }

    private static IdentityKeysAttribute[] getResults(String urlCB) {
        cdp_token = UnifiedCustomerController.getCDPToken();
        List<IdentityKeysAttribute> records = new List<IdentityKeysAttribute>();  
        UnifiedIndividualAddressParser unifiedIndKeysAttrs; 
        Boolean errorFlag = false;             
        Map<String, IdentityKeysAttribute> unifiedIndividualIdentityKeysMap = new Map<String, IdentityKeysAttribute>();
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        // req.setMethod('GET');
        // req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // req.setEndpoint(urlCB);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + cdp_token);
        req.setTimeout(20000);
        req.setBody(urlCB);
        req.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');        
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> address output ' + res.getBody()); 

        try{
            unifiedIndKeysAttrs = (UnifiedIndividualAddressParser) JSON.deserialize(res.getBody().replaceAll('__c',''),UnifiedIndividualAddressParser.class); 
        }catch(Exception ex) {
            errorFlag = true;
            System.debug(LoggingLevel.ERROR, '---> Error ' + ex.getMessage());
        }

        if(errorFlag) {
            records = getSeedData();
            return records;
        }

        //LTV Records


        
        List<UnifiedIndividualAddressParser.Data> keys = unifiedIndKeysAttrs.Data;   
        for(UnifiedIndividualAddressParser.Data key : keys) {     
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

    private static void LTVDML(String token, String customerId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + cdp_token);
        req.setTimeout(20000);        
        req.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/insight/calculated-insights/Profile_View_Purchase_Metrics__cio?filters=[CustomerId__c='+unifiedIndividualId+']');        
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> LTV output ' + res.getBody()); 
        LTV LTVAttrs = (LTV) JSON.deserialize(res.getBody().replaceAll('__c',''),LTV.class); 
        //insert into C360_LTV__C
        List<LTV.Data> keys = LTVAttrs.Data;
        List<C360_LTV__c> LTVs = new List<C360_LTV__c>();
        for(LTV.Data key : keys) {
            C360_LTV__c c360LTV = new C360_LTV__c();
            c360LTV.Name = key.CustomerId;
            c360LTV.CustomerId__c = key.CustomerId;
            c360LTV.AvgOrderAmount__c = Decimal.valueOf(key.AvgOrderAmount);
            c360LTV.HighestOrderAmount__c = Decimal.valueOf(key.HighestOrderAmount);
            c360LTV.LowestOrderAmount__c = Decimal.valueOf(key.LowestOrderAmount);
            c360LTV.TotalLifetimeOrders__c = Integer.valueOf(key.TotalLifetimeOrders);
            c360LTV.TotalLifetimeSpend__c = Decimal.valueOf(key.TotalLifetimeSpend);
            LTVs.add(c360LTV);
        } 
        try{
            insert LTVs;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error inserting LTV records : ' + ex.getMessage());
        }                    

    }
    //Set LTV Attributes
    private static void LTVController() {
        // params
        System.debug(LoggingLevel.DEBUG, 'LTVCtrl cdp token : ' + cdp_token);
        System.debug(LoggingLevel.DEBUG, 'LTVCtrl unified id : ' + unifiedIndividualId);
        List<C360_LTV__c> records = [SELECT Id from C360_LTV__c];
        try{
            Database.DeleteResult[] srList = Database.delete(records, false);
            if(srList.size() < 1) {
                LTVDML(cdp_token, unifiedIndividualId);
            }
            // Iterate through each returned result
            for (Database.DeleteResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    //make a connection to CDP get the JSON
                    LTVDML(cdp_token, unifiedIndividualId);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }            
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error deleting LTV records : ' + ex.getMessage());
        }
    }
    @future(callout=true)
    private static void SalesOrderDML(List<String> attibutes) {
        String c360_token = UnifiedCustomerController.getCDPToken();
        System.debug(LoggingLevel.DEBUG, 'SalesOrderDML cdp token : ' + c360_token);
        System.debug(LoggingLevel.DEBUG, 'SalesOrderDML unified id : ' + attibutes[1]);        
        String urlCB = '{' + '"sql"' + ':' + '"select UI.Id__c, GP.ProductSKU__c,GP.Product_Name__c, SOP.Sale_Price_Amount__c, SO.PurchaseOrderDate__c from ' + 
                        'UnifiedIndividual__dlm UI INNER JOIN IndividualIdentityLink__dlm IIL on UI.Id__c=IIL.UnifiedRecordId__c INNER JOIN SalesOrder__dlm SO ' + 
                        'on IIL.SourceRecordId__c=SO.SoldToCustomerId__c INNER JOIN SalesOrderProduct__dlm SOP on SO.OrderNumber__c=SOP.SalesOrderId__c ' + 
                        'INNER JOIN GoodsProduct__dlm GP on SOP.ProductId__c=GP.ProductSKU__c where UI.Id__c= \'' + attibutes[1] + '\'' + 
                        ' Order By SO.PurchaseOrderDate__c DESC' + '"}';  
        System.debug(LoggingLevel.DEBUG, urlCB);
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + c360_token);
        req.setTimeout(20000);
        req.setBody(urlCB);       
        req.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> SalesOrder output ' + res.getBody());  
        RecentSalesOrders salesOrders = (RecentSalesOrders) JSON.deserialize(res.getBody().replaceAll('__c',''),RecentSalesOrders.class);

        List<RecentSalesOrders.Data> keys = salesOrders.Data;
        List<C360_Recent_Sales_Order__c> salesOrdersList = new List<C360_Recent_Sales_Order__c>();
        for(RecentSalesOrders.Data key : keys) {
            C360_Recent_Sales_Order__c c360SO = new C360_Recent_Sales_Order__c();
            c360SO.Customer_Id__c = attibutes[1];
            c360SO.Product_Name__c = key.Product_Name;
            c360SO.ProductSKU__c = key.ProductSKU;
            c360SO.Purchase_Order_Date__c = Date.valueOf(key.PurchaseOrderDate);
            c360SO.Sale_Price_Amount__c = Decimal.valueOf(key.Sale_Price_Amount);
            salesOrdersList.add(c360SO);
        } 
        try{
            insert salesOrdersList;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error inserting LTV records : ' + ex.getMessage());
        }

    }
    private static void SalesOrderController() {
        List<C360_Recent_Sales_Order__c> records = [SELECT Id from C360_Recent_Sales_Order__c];  
        List<String> attributes = new List<String>();
        attributes.add(cdp_token);
        attributes.add(unifiedIndividualId);              
        try{
            System.debug(LoggingLevel.DEBUG, 'record #' + records.size());
            if(records.size() < 1) {
                System.debug(LoggingLevel.DEBUG, 'No sales orders records to delete');
                SalesOrderDML(attributes);
            }else {
                Database.DeleteResult[] srList = Database.delete(records, false);
                // Iterate through each returned result
                for (Database.DeleteResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully deleted sales order. ID: ' + sr.getId());
                        //make a connection to CDP get the JSON
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }  
                System.debug(LoggingLevel.DEBUG, 'Deleted all sales orders records.');                          
                SalesOrderDML(attributes);
            }

        }catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error deleting Sales orders : ' + ex.getMessage());
        }
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

    private static List<IdentityKeysAttribute> getSeedData() {
        List<IdentityKeysAttribute> records = new List<IdentityKeysAttribute>();
        IdentityKeysAttribute record = new IdentityKeysAttribute();
        record.Id = '1';
        record.AddressLine1 = '15 Braveheart Lane';
        record.City = 'New York';
        record.Country = 'US';
        record.PostalCode = '10011';
        record.State = 'NY';
        records.add(record);
        return records;
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