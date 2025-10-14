public class CaseTriggerHandler  extends TriggerHandler {
    private static final Map<Id, Account> accountsMap = new Map<Id, Account>();

    public override void beforeInsert(List<SObject> newObjects){
        List<Case> newCases = (List<Case>)newObjects;

    }

    public override void afterInsert(List<SObject> newObjects){

    }

    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects){
        
    }
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects){
        
    }
}