public class RecentSalesOrders {

	public class Data {
		public String Sale_Price_Amount;
		public String ProductSKU;
		public String PurchaseOrderDate;
		public String Product_Name;
		public String Id;
		public String Image_Link;
		public String Product_URL;
	}

	public List<Data> data;
	public String startTime;
	public String endTime;
	public Integer rowCount;
	public String queryId;
	public Boolean done;

	
	public static RecentSalesOrders parse(String json) {
		return (RecentSalesOrders) System.JSON.deserialize(json, RecentSalesOrders.class);
	}
}