public class LTV {

	public class Data {
		public String TotalLifetimeOrders;
		public String TotalLifetimeSpend;
		public String CustomerId;
		public String HighestOrderAmount;
		public String AvgOrderAmount;
		public String LowestOrderAmount;
	}

	public List<Data> data;

	
	public static LTV parse(String json) {
		return (LTV) System.JSON.deserialize(json, LTV.class);
	}
}
