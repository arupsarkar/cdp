public with sharing class SalesOrderController {
    public SalesOrderController() {

    }

    @AuraEnabled
    public static LifeTimeDataAttributes[] getSalesOrders(String searchParam) {
        Set<String> searchParams = new Set<String>();
        searchParams.add(searchParam);
        String queryCriteria = '';
        string queryREST = '';
        queryCriteria = getQueryCriteria(searchParams);
        List<LifeTimeDataAttributes> records = new List<LifeTimeDataAttributes>();  
        LifeTimeDataAttributes record = new LifeTimeDataAttributes();
        records.add(record);
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

    public class LifeTimeDataAttributes {
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public Decimal ltvSpend {get; set;} 
        @AuraEnabled public Integer ltvOrders {get; set;} 
        @AuraEnabled public Decimal avgOrderAmount {get; set;} 
        @AuraEnabled public Decimal highestOrderAmount {get; set;} 
        @AuraEnabled public Decimal lowestOrderAmount {get; set;} 

        LifeTimeDataAttributes() {

            List<C360_LTV__c> ltvs = [SELECT CustomerId__c, AvgOrderAmount__c, HighestOrderAmount__c, LowestOrderAmount__c,
                                        TotalLifetimeOrders__c, TotalLifetimeSpend__c
                                        FROM C360_LTV__c LIMIT 1];
            if(ltvs.size() > 0) {
                Id = ltvs[0].CustomerId__c;
                ltvOrders = Integer.valueOf(ltvs[0].TotalLifetimeOrders__c);
                ltvSpend = ltvs[0].TotalLifetimeSpend__c;
                avgOrderAmount = ltvs[0].AvgOrderAmount__c;
                highestOrderAmount = ltvs[0].HighestOrderAmount__c;
                lowestOrderAmount = ltvs[0].LowestOrderAmount__c;
            }

        }
    }

    private static integer getLtvOrders(Integer criteria) {
        Integer result = 0;
        result = Integer.valueof((Math.random() * criteria));
        return result;
    }

    private static Decimal getLtvSpend(Integer criteria) {
        Decimal result = 0;
        result = Decimal.valueof((Math.random() * criteria));
        result = Math.round(result * 100) / 100.0;
        return result;
    } 
    
    private static Decimal getAvgOrderAmount(Integer orders, Decimal amount) {
        Decimal result = 0.00;
        result = amount/orders;
        result = Math.round(result * 100) / 100.0;
        return result;
    }
}
