public class UnifiedIndividualPhoneParser {

	public List<Data> data;
	public String startTime;
	public String endTime;
	public Integer rowCount;
	public String queryId;

	public class Data {
		public String TelephoneNumber;
		public String PartyId;
		public String Id;
	}

	
	public static UnifiedIndividualPhoneParser parse(String json) {
		return (UnifiedIndividualPhoneParser) System.JSON.deserialize(json, UnifiedIndividualPhoneParser.class);
	}




}