public class UnifiedSegmentParser {

	public class Metadata {
		public IdParser Id {get;set;} 
		public IdParser segmentname {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Id__c') {
							Id = new IdParser(parser);
						} else if (text == 'segmentname__c') {
							segmentname = new IdParser(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String Id {get;set;} 
		public String segmentname {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Id__c') {
							Id = parser.getText();
						} else if (text == 'segmentname__c') {
							segmentname = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class IdParser {
		public Integer placeInOrder {get;set;} 
		public Integer typeCode {get;set;} 
		public String type_Z {get;set;} // in json: type

		public IdParser (JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'placeInOrder') {
							placeInOrder = parser.getIntegerValue();
						} else if (text == 'typeCode') {
							typeCode = parser.getIntegerValue();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Id__c consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Data> data {get;set;} 
	public String startTime {get;set;} 
	public String endTime {get;set;} 
	public Integer rowCount {get;set;} 
	public String queryId {get;set;} 
	public Boolean done {get;set;} 
	public Metadata metadata {get;set;} 

	public UnifiedSegmentParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'data') {
						data = arrayOfData(parser);
					} else if (text == 'startTime') {
						startTime = parser.getText();
					} else if (text == 'endTime') {
						endTime = parser.getText();
					} else if (text == 'rowCount') {
						rowCount = parser.getIntegerValue();
					} else if (text == 'queryId') {
						queryId = parser.getText();
					} else if (text == 'done') {
						done = parser.getBooleanValue();
					} else if (text == 'metadata') {
						metadata = new Metadata(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'UnifiedSegmentParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static UnifiedSegmentParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new UnifiedSegmentParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

    private static List<Data> arrayOfData(System.JSONParser p) {
        List<Data> res = new List<Data>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data(p));
        }
        return res;
    }

}