public class CaseTriggerHandler  extends TriggerHandler {
    private static final Map<Id, Account> accountsMap = new Map<Id, Account>();

    public override void beforeInsert(List<SObject> newCases){
        mainProcessBefore(null, newCases);

    }

    public override void afterInsert(List<SObject> newCases){
        mainProcessAfter(null, newCases);
    }

    public override void beforeUpdate(List<SObject> oldCases, List<SObject> newCases){
        mainProcessBefore(new Map<Id, Case>((List<Case>) oldCases), newCases);
        
    }
    public override void afterUpdate(List<SObject> oldCases, List<SObject> newCases){
        mainProcessAfter(new Map<Id, Case>((List<Case>) oldCases), newCases);
        
    }

    //TODO rename method
    private void mainProcessBefore(Map<Id, Case> oldCasesMap, List<Case> newCases) {
        Map<Id, Account> accountsById = getParentAccountsById(newCases);

        for (Case newCase : newCases) {
            Case oldCase = oldCasesMap?.get(newCase.Id);
            Id accountId = newCase.AccountId;
            Account parentAccount = accountsById.get(accountId);

            updateIfPatentAccountChanged(newCase, oldCase, parentAccount);
            updateFirstClosedDate(newCase, oldCase);
            //TODO these 3 method can be combined in one method
            fillHierarchyLevel(newCase, oldCase, parentAccount);
            fillShipTo(newCase, oldCase, parentAccount);
            fillSoldTo(newCase, oldCase, parentAccount);
        }
    }

    //TODO rename method
    private void mainProcessAfter(Map<Id, Case> oldCasesMap, List<Case> newCases) {
        if (newCases == null || newCases.isEmpty()) return;

         Map<Id, Account> accountsById = getParentAccountsById(newCases);

        Map<Id, RecordType> caseRecordTypeById = new Map<Id, RecordType>([
            SELECT Id, SobjectType, DeveloperName
            FROM RecordType
            WHERE SobjectType = 'Case'
        ]);

        for (Case newCase : newCases) {
            //TODO Do nothing here
            updateIfNothingForComplaintsHere(newCase, caseRecordTypeById.get(newCase.RecordTypeId));
            createTaskWhenDueDateIsSet(newCase, oldCasesMap?.get(newCase.Id), accountsById.get(newCase.AccountId));
        }
    }

    //TODO Do nothing here
    private Case updateIfNothingForComplaintsHere(Case newCase, RecordType caseRecordType) {
        if (newCase == null) return null;

        if (caseRecordType?.Description == 'Complaint') {
            newCase.CurrencyIsoCode = newCase.CurrencyIsoCode;
        }

        return newCase;
    }

    private Case updateIfPatentAccountChanged(Case newCase, Case oldCase, Account parentAccount) {
        if (newCase == null) return null;

        if ((oldCase == null || newCase.AccountId != oldCase.AccountId)
                && newCase.accountId != null
                && parentAccount?.BuyerGroup__c != null
        ) {
            newCase.Parent_Account_Buyer_Group__c = parentAccount.BuyerGroup__c;
        }

        return newCase;
    }

    private Case updateFirstClosedDate(Case newCase, Case oldCase) {
        if (newCase == null || oldCase == null) return null;

         if (newCase.Status != oldCase.Status
            && newCase.Status == 'Closed'
            && newCase.ClosedDate_First__c == null
        ) {
            newCase.ClosedDate_First__c = Datetime.now();
        }

        return newCase;
    }

    private Case fillHierarchyLevel(Case newCase, Case oldCase, Account parentAccount) {
        if (newCase == null || oldCase == null || parentAccount == null) return null;

        Boolean isAccountIdChanged = newCase.AccountId != null
            && (newCase.AccountId != oldCase.AccountId);

        Boolean fillHierarchyForCh4 = parentAccount.CHLevel__c == '4'
            && parentAccount.Division_Division__c != '20';

        if (isAccountIdChanged && fillHierarchyForCh4) {
            newCase.CH1__c = parentAccount.Parent?.Parent?.ParentId;
            newCase.CH2__c = parentAccount.Parent?.ParentId;
            newCase.CH3__c = parentAccount.ParentId;
        }

        Boolean fillHierarchyForCh3 = parentAccount.CHLevel__c == '3';

        if (isAccountIdChanged && fillHierarchyForCh3) {
            newCase.CH1__c = parentAccount.Parent?.ParentId;
            newCase.CH2__c = parentAccount.ParentId;
            newCase.CH3__c = parentAccount.Id;
        }

        Boolean fillHierarchyForCh2 = parentAccount.CHLevel__c == '2';

        if (isAccountIdChanged && fillHierarchyForCh2) {
            newCase.CH1__c = parentAccount.ParentId;
            newCase.CH2__c = parentAccount.Id;
        }

        return newCase;
    }

    private Case fillShipTo(Case newCase, Case oldCase, Account parentAccount) {
        if (newCase == null || oldCase == null || parentAccount == null) return null;

        Boolean isAccountIdChanged = newCase.AccountId != null
            && (newCase.AccountId != oldCase.AccountId);

        Boolean fillShipToForCh4 = parentAccount.GeneralDataAccount__c != null
            && parentAccount.CHLevel__c == '4'
            && parentAccount.GeneralDataAccountGroup__c == 'ShipTo';

        if (isAccountIdChanged && fillShipToForCh4) {
            newCase.ShipTo__c = newCase.AccountId;
            newCase.SoldTo__c = null;
        }

        return newCase;
    }

    private Case fillSoldTo(Case newCase, Case oldCase, Account parentAccount) {
        if (newCase == null || oldCase == null || parentAccount == null) return null;

        Boolean isAccountIdChanged = newCase.AccountId != null
            && (newCase.AccountId != oldCase.AccountId);

        Boolean fillSoldToForCh4 = parentAccount.CHLevel__c == '4'
            && parentAccount.GeneralDataAccountGroup__c != null
            && parentAccount.GeneralDataAccountGroup__c == 'SoldTo';

        if (isAccountIdChanged && fillSoldToForCh4) {
            newCase.ShipTo__c = null;
            newCase.SoldTo__c = newCase.AccountId;
        }

        return newCase;
    }

    private Task createTaskWhenDueDateIsSet(Case newCase, Case oldCase, Account parentAccount){
        if (newCase == null || oldCase == null) return null;

        Boolean isDueDateSet = newCase.DueDate_Customer__c != oldCase.DueDate_Customer__c
            && newCase.DueDate_Customer__c != null
            && newCase.AccountId != null
            && oldCase.DueDate_Customer__c == null
            && newCase.OwnerId.toString().startsWith('005');

        if (!isDueDateSet) return null;

        String newTaskSubject = newCase.AccountId == null
            ? 'Request with Subject "' + newCase.Subject + '" is due in two days.'
            : 'Request for ' + parentAccount.Name + ' with Subject "' + newCase.Subject + '" is due in two days.';

        Task newTask = new Task();
        newTask.ActivityDate = newCase.DueDate_Customer__c;
        newTask.CurrencyIsoCode = 'EUR';
        newTask.IsReminderSet = true;
        newTask.OwnerId = newCase.OwnerId;
        newTask.ReminderDateTime = newCase.DueDate_Customer__c.addDays(-2);
        newTask.Status = 'Open';
        newTask.Subject = newTaskSubject;
        newTask.WhatId = newCase.Id;

        insert newTask;

        return newTask;
    }

    private Map<Id, Account> getParentAccountsById(List<Case> cases) {
        if (cases == null || cases.isEmpty()) {
            return new Map<Id, Account>();
        }

        Set<Id> parentAccountIds = getIds(cases, 'AccountId');

        return new Map<Id, Account>([
            //TODO maybe we need only one parent level, the most deep
            SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId, BuyerGroup__c
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);
    }

    private Set<Id> getIds(List<SObject> records, String fieldName) {
        Set<Id> ids = new Set<Id>();

        if (records == null || records.isEmpty() || String.isBlank(fieldName)) return ids;
        
        for (SObject record : records) {
            Object idObj = record.get(fieldName);
            if (idObj == null ||!(idObj instanceof Id)) {
                continue;
            }
            
            ids.add((Id) idObj);
        }

        return ids;
    }


}