/**
 * @description       : 
 * @author            : Roman Hnativ
 * @group             : 
 * @last modified on  : 01-14-2021
 * @last modified by  : Roman Hnativ
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   01-14-2021   Roman Hnativ   Initial Version
**/
public class Utility {
    public static Map<String, Map<String, RecordType> > RecordTypeMap = new Map<String, Map<String, RecordType> >();

    // Function that maps the RecordType by DeveloperName and returns The Id.
    public static Id getRecordTypeIdByDeveloperName(String SObjectName, String DeveloperName) {
        Map<String, RecordType> objectRTMap = RecordTypeMap.get(SObjectName);
        if (objectRTMap == null) {
            objectRTMap = new Map<String, RecordType>();

            List<RecordType> RecordTypeList = [
                SELECT Id, Developername, SObjectType
                FROM RecordType
                WHERE SObjectType = :SObjectName
            ];

            for (RecordType RT : RecordTypeList) {
                objectRTMap.put(RT.DeveloperName, RT);
            }

            RecordTypeMap.put(SObjectName, objectRTMap);
        }

        Id RecordtypeId = objectRTMap.get(DeveloperName).Id;

        return RecordTypeId;
    }


    public static String formatNumberFields(Decimal unformattedValue, Integer scale) {
      String formattedValue = unformattedValue.setScale(scale).format();
      Integer decimalPlaces;
      String decimalSep = 0.23.format().substring(1, 2);
  
      if(formattedValue.contains(decimalSep)) {
          decimalPlaces = formattedValue.split('\\' + decimalSep)[1].length();
      } else {
          formattedValue += decimalSep;
          decimalPlaces = 0;
      }
  
      //Add trailing zeros
      while(decimalPlaces < scale) {
          formattedValue += '0';
          decimalPlaces ++;
      }
  
      return formattedValue;
  }

   public static Decimal roundDecimal(Boolean isRetailOpportunity, Decimal value) {
        if (value == null) {
            return value;
        }

        if(isRetailOpportunity) {
            return value.setScale(4);
        } else {
            return value.setScale(2);
        }
    }
}