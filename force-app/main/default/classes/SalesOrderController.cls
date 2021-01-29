public with sharing class SalesOrderController {
    public SalesOrderController() {

    }

    @AuraEnabled(cacheable=true)
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

        LifeTimeDataAttributes() {
            Id = 'some ramdom id';
            ltvOrders = getLtvOrders(10);
            ltvSpend = getLtvSpend(1000);
            avgOrderAmount = getAvgOrderAmount(ltvOrders, ltvSpend);
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
