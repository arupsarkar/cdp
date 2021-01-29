public class UnifiedIndividualParser {

	public List<Data> data;
	public String startTime;
	public String endTime;
	public Integer rowCount;
	public String queryId;

	public class Data {
		public String Channel_Preference;
		public String Interest;
		public String GenderId;
		public String Category_Preference;
		public String LastName;
		public String LoyaltyStatus;		
		public String Id;
		public String BirthDate;
		public String InternalOrganizationId;
		public String LoyaltyPoints;		
		public String FirstName;
	}

	
	public static UnifiedIndividualParser parse(String json) {
		return (UnifiedIndividualParser) System.JSON.deserialize(json, UnifiedIndividualParser.class);
	}



}