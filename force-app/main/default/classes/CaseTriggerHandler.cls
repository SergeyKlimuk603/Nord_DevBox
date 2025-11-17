/****************************************************************************************************
* Class CaseTriggerHandler
*
*   Create By   :  Andrei Pivavarchyk (mindsquare GmbH)
*   Create Date :  10.09.2025
*   Description  : Trigger Handler for the Case
*
*   Modification Log:
*   -------------------------------------------------------------------------------------------------
*   * Developer                             Date           Description
*   * -----------------------------------------------------------------------------------------------
*   * Andrei Pivavarchyk (mindsquare GmbH)  10.09.2025     Init version.
****************************************************************************************************/

public class CaseTriggerHandler extends TriggerHandler {
    private static final String CASE_OBJECT_NAME = 'Case';
    private static final String CASE_COMPLAINT_RECORD_TYPE = 'Complaint';
    private static final String CASE_STATUS_CLOSED = 'Closed';
    private static final Id COMPLAINT_RECORD_TYPE_ID = Utility.getRecordTypeIdByDeveloperName(CASE_OBJECT_NAME, CASE_COMPLAINT_RECORD_TYPE);
    private static final String UPDATE_CURRENCY_CODE = 'UPDATE_CURRENCY_CODE';
    private static final String CREATE_TASK = 'CREATE_TASK';
    private static Map<String, Set<Id>> processedCaseIdsByProcessName = new Map<String, Set<Id>>{
            UPDATE_CURRENCY_CODE => new Set<Id>(),
            CREATE_TASK => new Set<Id>()
    };

    public override void beforeInsert(List<SObject> newCases) {
        mainProcessBefore(null, newCases);
    }

    public override void afterInsert(List<SObject> newCases) {
        mainProcessAfter(null, newCases);
    }

    public override void beforeUpdate(List<SObject> oldCases, List<SObject> newCases) {
        mainProcessBefore(new Map<Id, Case>((List<Case>) oldCases), newCases);

    }
    public override void afterUpdate(List<SObject> oldCases, List<SObject> newCases) {
        mainProcessAfter(new Map<Id, Case>((List<Case>) oldCases), newCases);
    }

    private void mainProcessBefore(Map<Id, Case> oldCasesMap, List<Case> newCases) {
        Map<Id, Account> accountsById = getParentAccountsById(newCases);

        for (Case newCase : newCases) {
            Case oldCase = oldCasesMap?.get(newCase.Id);
            Id accountId = newCase.AccountId;
            Account parentAccount = accountsById.get(accountId);

            updateIfParentAccountChanged(newCase, oldCase, parentAccount);
            //Before update
            if (oldCase != null) {
                updateFirstClosedDate(newCase, oldCase);
                fillHierarchyLevel(newCase, oldCase, parentAccount);
                fillShipTo(newCase, oldCase, parentAccount);
                fillSoldTo(newCase, oldCase, parentAccount);
            }
        }
    }

    private void mainProcessAfter(Map<Id, Case> oldCasesMap, List<Case> newCases) {
        if (newCases == null || newCases.isEmpty()) return;

        Map<Id, Account> accountsById = getParentAccountsById(newCases);

        List<Task> tasksToInsert = new List<Task>();
        List<Case> complaintCasesToUpdate = new List<Case>();

        for (Case newCase : newCases) {
            if (!processedCaseIdsByProcessName.get(UPDATE_CURRENCY_CODE).contains(newCase.Id)
                    && newCase.RecordTypeId == COMPLAINT_RECORD_TYPE_ID) {
                complaintCasesToUpdate.add(
                        new Case(Id = newCase.Id, CurrencyIsoCode = newCase.CurrencyIsoCode)
                );
                processedCaseIdsByProcessName.get(UPDATE_CURRENCY_CODE).add(newCase.Id);
            }

            Case oldCase = oldCasesMap?.get(newCase.Id);
            if(oldCase!=null && !processedCaseIdsByProcessName.get(CREATE_TASK).contains(newCase.Id) ){
                Task newTask = createTaskWhenDueDateIsSet(newCase, oldCase, accountsById.get(newCase.AccountId));
                if (newTask != null) {
                    tasksToInsert.add(newTask);
                    processedCaseIdsByProcessName.get(CREATE_TASK).add(newCase.Id);
                }
            }
        }
        update complaintCasesToUpdate;
        insert tasksToInsert;
    }

    private static Case updateIfParentAccountChanged(Case newCase, Case oldCase, Account parentAccount) {
        if (newCase == null) return null;

        if ((oldCase == null || newCase.AccountId != oldCase.AccountId)
                && newCase.AccountId != null
                && parentAccount?.BuyerGroup__c != null
        ) {
            newCase.Parent_Account_Buyer_Group__c = parentAccount.BuyerGroup__c;
        }
        return newCase;
    }

    private static Case updateFirstClosedDate(Case newCase, Case oldCase) {
        if (newCase == null || oldCase == null) return null;

        if (newCase.Status != oldCase.Status
                && newCase.Status == CASE_STATUS_CLOSED
                && newCase.ClosedDate_First__c == null
        ) {
            newCase.ClosedDate_First__c = Datetime.now();
        }

        return newCase;
    }

    private static Case fillHierarchyLevel(Case newCase, Case oldCase, Account parentAccount) {
        if (newCase == null || oldCase == null || parentAccount == null) return null;

        Boolean isAccountIdChanged = newCase.AccountId != null
                && (newCase.AccountId != oldCase.AccountId);

        Boolean fillHierarchyForCh4 = parentAccount.CHLevel__c == '4'
                && parentAccount.Division_Division__c != '20';

        Boolean fillHierarchyForCh3 = parentAccount.CHLevel__c == '3';

        if (isAccountIdChanged && fillHierarchyForCh4) {
            newCase.CH1__c = parentAccount.Parent?.Parent?.ParentId;
            newCase.CH2__c = parentAccount.Parent?.ParentId;
            newCase.CH3__c = parentAccount.ParentId;
        }

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

    private static Case fillShipTo(Case newCase, Case oldCase, Account parentAccount) {
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

    private static Case fillSoldTo(Case newCase, Case oldCase, Account parentAccount) {
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

    private static Task createTaskWhenDueDateIsSet(Case newCase, Case oldCase, Account parentAccount) {
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

        return newTask;
    }

    private Map<Id, Account> getParentAccountsById(List<Case> cases) {
        if (cases == null || cases.isEmpty()) {
            return new Map<Id, Account>();
        }

        Set<Id> parentAccountIds = Utility.getIds(cases, 'AccountId');

        return new Map<Id, Account>([
                SELECT Id, Name, BuyerGroup__c, CHLevel__c, Division_Division__c, GeneralDataAccount__c,
                        GeneralDataAccountGroup__c, ParentId, Parent.ParentId, Parent.Parent.ParentId
                FROM Account
                WHERE Id IN :parentAccountIds
        ]);
    }
}