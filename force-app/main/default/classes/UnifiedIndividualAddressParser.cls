
public class UnifiedIndividualAddressParser {

	public List<Data> data;
	public String startTime;
	public String endTime;
	public Integer rowCount;
	public String queryId;

	public class Data {
		public String PartyId;		
		public String AddressLine1;
		public String AddressLine2;
		public String CityName;
		public String StateProvinceName;
		public String PostalCodeText;	
		public String CountryName;
		public String Id;
	}
	public static UnifiedIndividualAddressParser parse(String json) {
		return (UnifiedIndividualAddressParser) System.JSON.deserialize(json, UnifiedIndividualAddressParser.class);
	}	

}