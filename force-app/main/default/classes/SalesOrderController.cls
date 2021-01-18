public with sharing class SalesOrderController {
    public SalesOrderController() {

    }


    public class LifeTimeData {
        public String Id {get; set;}
        public Integer ltvSpend {get; set;} 
        public Integer ltvOrders {get; set;} 
        public Decimal avgOrderAmount {get; set;} 
    }
}
