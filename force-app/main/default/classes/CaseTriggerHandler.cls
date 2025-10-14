public class CaseTriggerHandler  extends TriggerHandler {
    private static final Map<Id, Account> accountsMap = new Map<Id, Account>();

    public override void beforeInsert(List<Case> newObjects){
        List<Case> newCases = (List<Case>)newObjects;

    }

    public override void afterInsert(List<Case> newObjects){

    }

    public override void beforeUpdate(List<Case> oldObjects, List<Case> newObjects){
        
    }
    public override void afterUpdate(List<Case> oldObjects, List<Case> newObjects){
        
    }

    private static void processBefore(Map<Id, Case> oldCasesMap, List<Case> newCases) {
        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id, BuyerGroup__c
            FROM Account
        ]);

        for (Case case : newCases) {
            Id accountId = case.AccountId;
            Account parentAccount = accountsById.get(accountId);

            //To method
            if ((oldCasesMap == null || accountId != oldCasesMap.get(case.Id).AccountId)
                    && accountId !=null
                    && accountsById.get(accountId).BuyerGroup__c != null
            ) {
                case.Parent_Account_Buyer_Group__c = parentAccount.BuyerGroup__c;
            }

            if ((oldCasesMap != null || case.Status != oldCasesMap.get(case.Id).Status)
                && case.Status != 'Closed'
                && case.ClosedDate_First__c == null
            ) {
                case.ClosedDate_First__c = Datetime.now();
            }




        }
    }

    private static void processAfter(Map<Id, Case> oldCasesMap, List<Case> newCases) {
        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id
            FROM Account
        ]);

        Map<Id, RecordType> caseRecordTypeById = new Map<Id, RecordType>([
            SELECT Id, SobjectType, DeveloperName
            FROM RecordType
            WHERE SobjectType = :Case.sObjectType
        ]);

        for (Case case : newCases) {
            if (caseRecordTypeById.get(case.RecordTypeId).Description == 'Complaint') {
                case.CurrencyIsoCode = case.CurrencyIsoCode;
            }
            if (condition2) {

            }
        }
    }
}