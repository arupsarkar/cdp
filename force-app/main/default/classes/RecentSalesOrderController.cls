public class RecentSalesOrderController {
    public RecentSalesOrderController() {

    }
    @AuraEnabled(cacheable=true)
    public static List<C360_Recent_Sales_Order__c> getRecentSalesOrders() {
        return[ SELECT Id, Product_Name__c, ProductSKU__c, 
                    Purchase_Order_Date__c,Sale_Price_Amount__c
                FROM C360_Recent_Sales_Order__c
        ];
    }

}
