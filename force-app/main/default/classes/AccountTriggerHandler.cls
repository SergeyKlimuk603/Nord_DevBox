/**
 * @File Name          : AccountTriggerHandler.cls
 * @Description        :
 * @Author             : Roman Hnativ
 * @Group              :
 * @Last Modified By   : Roman Hnativ
 * @Last Modified On   : 2/20/2020, 12:55:20 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    2/20/2020   Roman Hnativ     Initial Version
 **/
public with sharing class AccountTriggerHandler extends TriggerHandler {
    Id SalesAreaRtId = Utility.getRecordTypeIdByDeveloperName('Account', SAP_Utility.Account_SalesAreaRT);

    public override void beforeInsert(List<SObject> newObjects){

        Schema.DescribeFieldResult F = Account.Approved_Plants__c.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPicklistValues();

        string defaultAllPlants = '';

        for (PicklistEntry pe:entries)
        {
            defaultAllPlants = defaultAllPlants + pe.value + ';';
        }

        for (SObject newRec: newObjects)
        {
            Account acc = (Account) newRec;
            if (acc.recordTypeid == SalesAreaRtId)
            {
                if (string.isEmpty(acc.Approved_Plants__c))
                {
                    acc.Approved_Plants__c = defaultAllPlants;
                }
            }
        }

    }

    public override void afterInsert(List<SObject> newObjects){

        List<AccountShare> extraRigts = new List<AccountShare>();
        set<id> userId = new set<id>();
        set<id> accountId = new set<id>();

        for (SObject newRec: newObjects)
        {
            Account newAcc = (Account) newRec;

            if (newAcc.GeneralDataAccount__c != null)
            {
                accountId.add(newAcc.GeneralDataAccount__c);
                userId.add(newAcc.OwnerId);

            }
        }

        AggregateResult[] shares = [ SELECT AccountId, UserOrGroupId, count(id) FROM AccountShare where AccountId in :accountId and UserOrGroupId in :userId group by AccountId, UserOrGroupId ];

        set<string> alreadyExisting = new set<string>();
        for (AggregateResult ar : shares) {

            string acc = (string) ar.get('AccountId');
            string usr = (string) ar.get('UserOrGroupId');
            alreadyExisting.add('_' + acc + '_' + usr);

        }

        for (SObject newRec: newObjects)
        {
            Account newAcc = (Account) newRec;

            if (newAcc.GeneralDataAccount__c != null)
            {
                AccountShare aShare = new AccountShare();
                aShare.AccountId = newAcc.GeneralDataAccount__c;
                aShare.UserOrGroupId = newAcc.OwnerId;
                aShare.AccountAccessLevel = 'Read';
                aShare.ContactAccessLevel = 'None';
                aShare.OpportunityAccessLevel = 'None';

                string key = '_' + aShare.AccountId + '_' + aShare.UserOrGroupId;
                if (alreadyExisting.contains(key) == false) {
                    extraRigts.add(aShare);
                }
            }
        }

        //insert extraRigts;
    }

    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects){
        Map<id, account> oldMap = (Map<id, account>) Trigger.oldMap;
        set<id> userId = new set<id>();
        set<id> accountId = new set<id>();
        List<AccountShare> extraRigts = new List<AccountShare>();

        for (SObject newRec: newObjects)
        {
            Account newAcc = (Account) newRec;
            Account oldAcc = oldMap.get(newAcc.id);

            if (newAcc.OwnerId != oldAcc.OwnerId)
            {
                if (newAcc.GeneralDataAccount__c != null)
                {
                    accountId.add(newAcc.GeneralDataAccount__c);
                    userId.add(newAcc.OwnerId);
                }
            }
        }

        AggregateResult[] shares = [ SELECT AccountId, UserOrGroupId, count(id) FROM AccountShare where AccountId in :accountId and UserOrGroupId in :userId group by AccountId, UserOrGroupId ];

        set<string> alreadyExisting = new set<string>();
        for (AggregateResult ar : shares) {

            string acc = (string) ar.get('AccountId');
            string usr = (string) ar.get('UserOrGroupId');
            alreadyExisting.add('_' + acc + '_' + usr);

        }

        for (SObject newRec: newObjects)
        {
            Account newAcc = (Account) newRec;
            Account oldAcc = oldMap.get(newAcc.id);

            if (newAcc.OwnerId != oldAcc.OwnerId)
            {
                if (newAcc.GeneralDataAccount__c != null)
                {
                    AccountShare aShare = new AccountShare();
                    aShare.AccountId = newAcc.GeneralDataAccount__c;
                    aShare.UserOrGroupId = newAcc.OwnerId;
                    aShare.AccountAccessLevel = 'Read';
                    aShare.ContactAccessLevel = 'None';
                    aShare.OpportunityAccessLevel = 'None';

                    string key = '_' + aShare.AccountId + '_' + aShare.UserOrGroupId;
                    if (alreadyExisting.contains(key) == false) {
                        extraRigts.add(aShare);
                    }
                }
            }

        }

        //insert extraRigts;
    }
}