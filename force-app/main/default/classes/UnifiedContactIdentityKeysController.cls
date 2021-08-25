public with sharing class UnifiedContactIdentityKeysController {
    
    public static String cdp_token {get; set;}
    public static String queryCriteria {get; set;}
    public static String unifiedIndividualId {get; set;}
    public UnifiedContactIdentityKeysController() {}

    @AuraEnabled
    public static IdentityKeysAttribute[] getUnifiedIdentityKeysSearchList(String searchParam) {
        System.debug(LoggingLevel.DEBUG, '---> search params : ' + searchParam);
        unifiedIndividualId = getUnifiedId(searchParam);
        Set<String> searchParams = new Set<String>();
        searchParams.add(unifiedIndividualId);

        queryCriteria = getQueryCriteria(searchParams);
        String urlCB = '{' + '"sql"' + ':' + '"SELECT Id__c, PartyId__c, AddressLine1__c, AddressLine2__c, ' + 
            'CityName__c, StateProvinceName__c, CountryName__c, PostalCodeText__c ' +
        'FROM UnifiedContactPointAddress__dlm WHERE PartyId__c IN (' + queryCriteria + ') LIMIT 1"' + 
        '}';
        
        System.debug(LoggingLevel.DEBUG, '>>> final query ' + urlCB);
        List<IdentityKeysAttribute> records = new List<IdentityKeysAttribute>();  
        records = getResults(urlCB) ;
        mainController(unifiedIndividualId);        
        return records;     


        // call the main future controller to spawn all queries

    }

    private static String getUnifiedId(String data) {
        String result = '';
        if(data.length() > 0) {
            JSONParser parser = JSON.createParser(data);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'unifiedId')) {
                    // Get the value.
                    parser.nextToken();
                    result = parser.getText();
                }
            }
        }else {
            return null;
        }
        System.debug(LoggingLevel.DEBUG, 'unified id' + result);
        return result;

    }

    @future(callout=true)
    private static void mainController(String searchParam) {
        Map<String, String> objectValues = new Map<String, String>();

        unifiedIndividualId = searchParam;
        cdp_token = UnifiedCustomerController.getCDPToken();
        Set<String> searchParams = new Set<String>();
        searchParams.add(searchParam);
        queryCriteria = getQueryCriteria(searchParams); 
        System.debug(LoggingLevel.DEBUG, '---> queryCriteria : ' + queryCriteria);
        System.debug(LoggingLevel.DEBUG, '---> unifiedIndividualId : ' + unifiedIndividualId);
        String urlCB = '{' + '"sql"' + ':' + '"SELECT Id__c, PartyId__c, AddressLine1__c, AddressLine2__c, ' + 
            'CityName__c, StateProvinceName__c, CountryName__c, PostalCodeText__c ' +
        'FROM UnifiedContactPointAddress__dlm WHERE PartyId__c IN (' + queryCriteria + ') LIMIT 1"' + 
        '}';

        Http h = new Http();
        HttpRequest req = new HttpRequest(); 

        // Address -Start
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + cdp_token);
        req.setTimeout(20000);
        req.setBody(urlCB);
        req.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');        
        HttpResponse res = h.send(req);
        System.debug(LoggingLevel.DEBUG, '>>> address output ' + res.getBody()); 
        objectValues.put('Address', res.getBody());
        // Address -End

        //LTV Insights -Start
        Http h1 = new Http();
        HttpRequest req1 = new HttpRequest();         
        req1.setMethod('GET');
        req1.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req1.setHeader('Authorization', 'Bearer ' + cdp_token);
        req1.setTimeout(20000);        
        req1.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/insight/calculated-insights/Purchase_Insights__cio?filters=[CustomerId__c='+unifiedIndividualId+']' + '&dimensions=CustomerId__c');
        HttpResponse res1 = h1.send(req1);
        System.debug(LoggingLevel.DEBUG, '>>> LTV output ' + res1.getBody());
        objectValues.put('LTV', res1.getBody());
        //LTV Insights -End

        //SalesOrder -Start
        String query2 = '{' + '"sql"' + ':' + '"select UI.Id__c, GP.ProductSKU__c,GP.Product_Name__c, GP.Image_Link__c, GP.Product_URL__c, SOP.Sale_Price_Amount__c, SO.PurchaseOrderDate__c from ' + 
        'UnifiedIndividual__dlm UI INNER JOIN IndividualIdentityLink__dlm IIL on UI.Id__c=IIL.UnifiedRecordId__c INNER JOIN SalesOrder__dlm SO ' + 
        'on IIL.SourceRecordId__c=SO.SoldToCustomerId__c INNER JOIN SalesOrderProduct__dlm SOP on SO.OrderNumber__c=SOP.SalesOrderId__c ' + 
        'INNER JOIN GoodsProduct__dlm GP on SOP.ProductId__c=GP.ProductSKU__c where UI.Id__c= \'' + unifiedIndividualId + '\'' + 
        ' Order By SO.PurchaseOrderDate__c DESC' + '"}';
        Http h2 = new Http();
        HttpRequest req2 = new HttpRequest();                 
        req2.setMethod('POST');
        req2.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req2.setHeader('Authorization', 'Bearer ' + cdp_token);
        req2.setTimeout(20000);
        req2.setBody(query2);
        req2.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');        
        HttpResponse res2 = h2.send(req2);
        System.debug(LoggingLevel.DEBUG, '>>> sales order output ' + res2.getBody());
        objectValues.put('SalesOrder', res2.getBody()); 
        //SalesOrder -End


        //Engagement Model -Start
        //1. WebEngagement -Start

        String query3 = '{' + '"sql"' + ':' + '"select UI.Id__c as UnifiedId, WE.EngagementChannelId__c as EngagementChannel,WE.DeviceTypeTxt__c as EngagementDevice,WE.EngagementChannelActionId__c as ' + 
                        'EngagementEvent,WE.EngagementDateTm__c as EngagementTime,GP.ProductSKU__c,CC.contentname__c as Content, WE.DomainName__c, WE.Referrer_Medium__c, WE.Referrer_Campaign__c,WE.Referrer_Source__c,WE.DeviceOSName__c, GP.Product_Name__c from UnifiedIndividual__dlm UI INNER JOIN IndividualIdentityLink__dlm IIL on UI.Id__c =  ' +
                        'IIL.UnifiedRecordId__c INNER JOIN WebsiteEngagement__dlm WE on IIL.SourceRecordId__c = WE.IndividualId__c INNER JOIN GoodsProduct__dlm GP on WE.SKU__c = GP.ProductSKU__c INNER JOIN ' + 
                        'Content_Catalog__dlm CC on CC.contentid__c = WE.Content_ID__c where UI.Id__c = \'' + unifiedIndividualId + '\'' + 
                        ' Order by 5 DESC' +
                        '"}';  
        Http h3 = new Http();
        HttpRequest req3 = new HttpRequest(); 
        req3.setMethod('POST');
        req3.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req3.setHeader('Authorization', 'Bearer ' + cdp_token);
        req3.setTimeout(20000);
        req3.setBody(query3);       
        req3.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');
        HttpResponse res3 = h3.send(req3);
        System.debug(LoggingLevel.DEBUG, '>>> WebEngagementDML output ' + res3.getBody()); 
        objectValues.put('Engagement-Web', res3.getBody());
        //EngagementController(res3.getBody(), 'Web');
        //1. WebEngagement -End
        //2. MobileEngagement -Start
        String query4 = '{' + '"sql"' + ':' + '"select UI.Id__c as UnifiedId,DE.EngagementChannelId__c as EngagementChannel,DE.Device_Type__c as EngagementDevice,DE.EngagementChannelActionId__c as EngagementEvent,DE.EngagementDateTm__c as ' + 
                        'EngagementTime,GP.ProductSKU__c,CC.contentname__c as Content from UnifiedIndividual__dlm UI INNER JOIN IndividualIdentityLink__dlm IIL on UI.Id__c = IIL.UnifiedRecordId__c INNER JOIN ' +
                        'DeviceApplicationEngagement__dlm DE on IIL.SourceRecordId__c = DE.IndividualId__c INNER JOIN GoodsProduct__dlm GP on DE.sku__c = GP.ProductSKU__c INNER JOIN Content_Catalog__dlm CC on ' + 
                        'CC.ContentID__c = DE.ContentID__c where UI.Id__c = \'' + unifiedIndividualId + '\'' + 
                        ' Order by 5 DESC' +
                        '"}';  
        System.debug(LoggingLevel.DEBUG, urlCB);
        Http h4 = new Http();
        HttpRequest req4 = new HttpRequest(); 
        req4.setMethod('POST');
        req4.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req4.setHeader('Authorization', 'Bearer ' + cdp_token);
        req4.setTimeout(20000);
        req4.setBody(query4);       
        req4.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');
        HttpResponse res4 = h4.send(req4);
        System.debug(LoggingLevel.DEBUG, '>>> MobileEngagementDML output ' + res4.getBody());
        objectValues.put('Engagement-Mobile', res4.getBody());
        //EngagementController(res4.getBody(), 'Mobile');
        //2. MobileEngagement -End  

        //3. EmailEngagement -Start
        String query5 = '{' + '"sql"' + ':' + '"select UI.Id__c as UnifiedId,EE.EngagementChannelId__c as EngagementChannel,EE.EngagementChannelActionId__c as EngagementEvent,EE.EngagementDateTm__c as EngagementTime, SubjectLineTxt__c as ' + 
                        'EmailSubjectLine from UnifiedIndividual__dlm UI INNER JOIN IndividualIdentityLink__dlm IIL on UI.Id__c = IIL.UnifiedRecordId__c INNER JOIN EmailEngagement__dlm EE on IIL.SourceRecordId__c = ' +
                        'EE.IndividualId__c where UI.Id__c = \'' + unifiedIndividualId + '\'' + 
                        ' Order by 4 DESC' +
                        '"}';  
        Http h5 = new Http();
        HttpRequest req5 = new HttpRequest(); 
        req5.setMethod('POST');
        req5.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req5.setHeader('Authorization', 'Bearer ' + cdp_token);
        req5.setTimeout(20000);
        req5.setBody(query5);       
        req5.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');
        HttpResponse res5 = h5.send(req5);
        System.debug(LoggingLevel.DEBUG, '>>> EmailEngagementDML output ' + res5.getBody()); 
        objectValues.put('Engagement-Email', res5.getBody());
        //EngagementController(res5.getBody(), 'Email');                       
        //3. EmailEngagement -End                        
        //Engagement Model -End
        //SegmentMembership -Start
        String query6 = '{' + '"sql"' + ':' + '"select DISTINCT UI.Id__c,SM.segmentname__c from UnifiedIndividual__dlm UI  ' + 
                        'INNER JOIN IndividualIdentityLink__dlm IIL on UI.Id__c = IIL.UnifiedRecordId__c INNER JOIN Segment_Membership__dlm SM ' + 
                        'on IIL.SourceRecordId__c = SM.subscriberkey__c where UI.Id__c = \'' + unifiedIndividualId + '\'' + 
                        '"}';  
        Http h6 = new Http();
        HttpRequest req6 = new HttpRequest(); 
        req6.setMethod('POST');
        req6.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req6.setHeader('Authorization', 'Bearer ' + cdp_token);
        req6.setTimeout(20000);
        req6.setBody(query6);       
        req6.setEndpoint('https://g4zt8nl0gfst8mjtgrst8yjzmm.c360a.salesforce.com/api/v1/query');
        HttpResponse res6 = h6.send(req6);
        System.debug(LoggingLevel.DEBUG, '>>> SegmentMembershipDML output ' + res6.getBody());
        objectValues.put('SegmentMembership', res6.getBody());
        //SegmentMembership -End

        // Create a Map object, store the objectname as key and
        // value as the response string, pass it on to a different controller.
        mainDMLController(objectValues);
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

    private static void LTVDML(String res) {
        System.debug(LoggingLevel.DEBUG, '---> output ' + res);


        try{
            LTV LTVAttrs = (LTV) JSON.deserialize(res.replaceAll('__c',''),LTV.class); 
            List<LTV.Data> keys = LTVAttrs.Data;  
            List<C360_LTV__c> LTVs = new List<C360_LTV__c>();
            for(LTV.Data key : keys) {
                C360_LTV__c c360LTV = new C360_LTV__c();
                c360LTV.Name = key.CustomerId;
                c360LTV.CustomerId__c = key.CustomerId;
                c360LTV.AvgOrderAmount__c = Decimal.valueOf(key.AvgOrderAmount);
                c360LTV.HighestOrderAmount__c = Decimal.valueOf(key.HighestOrderAmount);
                c360LTV.LowestOrderAmount__c = Decimal.valueOf(key.LowestOrderAmount);
                c360LTV.TotalLifetimeOrders__c = Integer.valueOf(key.TotalOrders);
                c360LTV.TotalLifetimeSpend__c = Decimal.valueOf(key.TotalSpend);
                LTVs.add(c360LTV);
            }             

            insert LTVs;
        }catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getLineNumber());
            System.debug(LoggingLevel.ERROR, ex.getCause());
        }
    }

    private static void SalesOrderDML(String res) {
        RecentSalesOrders salesOrders = (RecentSalesOrders) JSON.deserialize(res.replaceAll('__c',''),RecentSalesOrders.class);
        List<RecentSalesOrders.Data> keys = salesOrders.data;
        List<C360_Recent_Sales_Order__c> salesOrdersList = new List<C360_Recent_Sales_Order__c>();
        for(RecentSalesOrders.Data key : keys) {
            C360_Recent_Sales_Order__c c360SO = new C360_Recent_Sales_Order__c();
            c360SO.Customer_Id__c = key.Id;
            c360SO.Product_Name__c = key.Product_Name;
            c360SO.ProductSKU__c = key.ProductSKU;
            c360SO.Purchase_Order_Date__c = Date.valueOf(key.PurchaseOrderDate);
            c360SO.Sale_Price_Amount__c = Decimal.valueOf(key.Sale_Price_Amount);
            c360SO.Image_Link__c = key.Image_Link;
            c360SO.Product_URL__c = key.Product_URL;
            salesOrdersList.add(c360SO);
        } 
        try{
            insert salesOrdersList;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error inserting LTV records : ' + ex.getMessage());
        }

    }


    private static void SegmentMembershipDML(String res) {
        
        UnifiedSegmentParser segmentMembership = (UnifiedSegmentParser) JSON.deserialize(res.replaceAll('__c',''),UnifiedSegmentParser.class);

        List<UnifiedSegmentParser.Data> keys = segmentMembership.Data;
        List<C360_Segment_Membership__c> segmentMembershipList = new List<C360_Segment_Membership__c>();
        for(UnifiedSegmentParser.Data key : keys) {
            C360_Segment_Membership__c c360SM = new C360_Segment_Membership__c();
            c360SM.Unified_Id__c = key.Id;
            c360SM.Segment_Name__c = getSegmentName(key.segmentname);
            segmentMembershipList.add(c360SM);
        } 
        try{
            insert segmentMembershipList;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error inserting SM records : ' + ex.getMessage());
        }        

    }
    private static String getSegmentName(String segmentName) {
        String result = segmentName;
        Integer underScore = segmentName.indexOf('_');
        if(underScore > 0) {
            result = segmentName.substring(0, underScore);
        }

        return result;
    }
    
    private static void WebEngagementDML(String res) {
        WebEngagementWrapper webEngagement = (WebEngagementWrapper) JSON.deserialize(res.replaceAll('__c',''),WebEngagementWrapper.class);
        List<WebEngagementWrapper.Data> keys = webEngagement.data;
        if(keys.size() < 1) {
            System.debug(LoggingLevel.DEBUG, '---> No web engagement records.');            
            return;
        }else {
            System.debug(LoggingLevel.DEBUG, '---> web engagement records size .' + keys.size());            
        }
        List<C360_Engagement_Timeline__c> engagementList = new List<C360_Engagement_Timeline__c>();
        for(WebEngagementWrapper.Data key : keys) {
            C360_Engagement_Timeline__c c360web = new C360_Engagement_Timeline__c();
            c360web.UnifiedId__c = key.UnifiedId;
            c360web.EngagementChannel__c = key.EngagementChannel;
            c360web.EngagementDevice__c = key.EngagementDevice;
            c360web.EngagementDateTime__c = key.EngagementTime != null ? Datetime.valueOf(key.EngagementTime.replace('T',' ')) : null;
            c360web.EngagementEvent__c = key.EngagementEvent;
            c360web.ProductSKU__c = key.ProductSKU;
            c360web.Domain__c = key.DomainName;
            c360web.Device_OS_Name__c = key.DeviceOSName;
            c360web.Referrer_Medium__c = key.Referrer_Medium;
            c360web.Content__c = key.Content;
            c360web.Referrer_Campaign__c = key.Referrer_Campaign;
            c360web.Referrer_Source__c = key.Referrer_Source;
            c360web.Product_Name__c = key.Product_Name;

            engagementList.add(c360web);
        } 
        try{
            //insert engagementList;
            System.debug(LoggingLevel.DEBUG, '---> Total # of records to be inserted ' + engagementList.size());            
            Database.SaveResult[] srList = Database.insert(engagementList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted engagement. Engagement ID: ' + sr.getId());
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
            System.debug(LoggingLevel.ERROR, 'Error inserting SM records : ' + ex.getMessage());
        }

    }
      
    private static void EngagementController(String res, String model) {
        if(model.equals('Web')) {
            WebEngagementDML(res);
        }
        if(model.equals('Mobile')) {
            MobileEngagementDML(res);
        }
        if(model.equals('Email')) {
            EmailEngagementDML(res);
        }                        
    }
    public static void MobileEngagementDML(String res) {
        DeviceEngagementWrapper deviceEngagement = (DeviceEngagementWrapper) JSON.deserialize(res.replaceAll('__c',''),DeviceEngagementWrapper.class);

        List<DeviceEngagementWrapper.Data> keys = deviceEngagement.Data;
        if(keys.size() < 1) {
            System.debug(LoggingLevel.DEBUG, '---> No device engagement records.');
            return;
        }        
        List<C360_Engagement_Timeline__c> engagementList = new List<C360_Engagement_Timeline__c>();
        for(DeviceEngagementWrapper.Data key : keys) {
            C360_Engagement_Timeline__c c360device = new C360_Engagement_Timeline__c();
            c360device.UnifiedId__c = key.UnifiedId;
            c360device.EngagementChannel__c = key.EngagementChannel;
            c360device.EngagementDevice__c = key.EngagementDevice;
            c360device.EngagementDateTime__c = Datetime.valueOf(key.EngagementTime.replace('T',' '));
            c360device.EngagementEvent__c = key.EngagementEvent;
            c360device.ProductSKU__c = key.ProductSKU;
            engagementList.add(c360device);
        } 
        try{
            //insert engagementList;
            System.debug(LoggingLevel.DEBUG, '---> Total # of records to be inserted ' + engagementList.size());            
            Database.SaveResult[] srList = Database.insert(engagementList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted engagement. Engagement ID: ' + sr.getId());
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
            System.debug(LoggingLevel.ERROR, 'Error inserting SM records : ' + ex.getMessage());
        }                
    }
    public static void EmailEngagementDML(String res) {
        EmailEngagementWrapper emailEngagement = (EmailEngagementWrapper) JSON.deserialize(res.replaceAll('__c',''),EmailEngagementWrapper.class);

        List<EmailEngagementWrapper.Data> keys = emailEngagement.Data;
        if(keys.size() < 1) {
            System.debug(LoggingLevel.DEBUG, '---> No email engagement records.');
            return;
        }        
        List<C360_Engagement_Timeline__c> engagementList = new List<C360_Engagement_Timeline__c>();
        for(EmailEngagementWrapper.Data key : keys) {
            C360_Engagement_Timeline__c c360email = new C360_Engagement_Timeline__c();
            c360email.UnifiedId__c = key.UnifiedId;
            c360email.EngagementChannel__c = key.EngagementChannel;
            c360email.EngagementDateTime__c = Datetime.valueOf(key.EngagementTime.replace('T',' '));
            c360email.EngagementEvent__c = key.EngagementEvent;
            c360email.SubjectLine__c = key.EmailSubjectLine;
            engagementList.add(c360email);
        } 
        try{
            //insert engagementList; 
            System.debug(LoggingLevel.DEBUG, '---> Total # of records to be inserted ' + engagementList.size());
            Database.SaveResult[] srList = Database.insert(engagementList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted engagement. Engagement ID: ' + sr.getId());
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
            System.debug(LoggingLevel.ERROR, 'Error inserting SM records : ' + ex.getMessage());
        }                        
    }
    private static void deleteDMLController() {

        //delete LTV -End
        //delete sales orders -Start        
        List<C360_Recent_Sales_Order__c> salesOrderRecords = [SELECT Id from C360_Recent_Sales_Order__c];  
        if(salesOrderRecords.size() > 0) {
            Database.DeleteResult[] drList1 = Database.delete(salesOrderRecords, true);
        }        
        //delete sales orders -End
        //delete engagement -Start
        List<C360_Engagement_Timeline__c> engagementRecords = [SELECT Id FROM C360_Engagement_Timeline__c];
        if(engagementRecords.size() > 0) {
            Database.DeleteResult[] drList2 = Database.delete(engagementRecords, true);
        }
        //delete engagement -End
        //delete segmentmembership -Start
        List<C360_Segment_Membership__c> segmentRecords = [SELECT Id FROM C360_Segment_Membership__c];
        if(segmentRecords.size() > 0) {
            Database.DeleteResult[] drList3 = Database.delete(segmentRecords, true);
        }        
        //delete segmentmembership -End
        //delete LTV -Start
        List<C360_LTV__c> ltvRecords = [SELECT Id from C360_LTV__c];        
        if(ltvRecords.size() > 0) {
            Database.DeleteResult[] drList4 = Database.delete(ltvRecords, true);
        }                        
    }
    private static void mainDMLController(Map<String, String> objectValues) {
        //Call all Deletes
        deleteDMLController();                
        for(String key : objectValues.keySet()) {
            //LTV
            if(key.contains('LTV')) {
                LTVDML(objectValues.get(key));                
            }            
            // salesorder
            if(key.contains('SalesOrder')) {
                SalesOrderDML(objectValues.get(key));                
            }
            //engagement
            if(key.contains('Engagement')) {
                if(key.contains('Web')) {
                    EngagementController(objectValues.get(key), 'Web');
                }
                if(key.contains('Mobile')) {
                    EngagementController(objectValues.get(key), 'Mobile');
                }
                if(key.contains('Email')) {
                    EngagementController(objectValues.get(key), 'Email');
                }                                                
            }
            //segment
            if(key.contains('SegmentMembership')) {
                SegmentMembershipDML(objectValues.get(key));
            }            
            
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