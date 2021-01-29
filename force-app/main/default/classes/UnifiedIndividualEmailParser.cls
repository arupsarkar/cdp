public class UnifiedIndividualEmailParser {

	public List<Data> data;
	public String startTime;
	public String endTime;
	public Integer rowCount;
	public String queryId;

	public class Data {
		public String PartyId;		
		public String EmailAddress;
		public String Id;
	}

	
	public static UnifiedIndividualEmailParser parse(String json) {
		return (UnifiedIndividualEmailParser) System.JSON.deserialize(json, UnifiedIndividualEmailParser.class);
	}




}