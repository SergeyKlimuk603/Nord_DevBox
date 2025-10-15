/**
 * @File Name          : OpportunityTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : Roman Hnativ
 * @Group              : 
 * @Last Modified By   : Roman Hnativ
 * @Last Modified On   : 6/26/2020, 8:40:57 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/10/2020   Roman Hnativ     Initial Version
**/
@istest
public class OpportunityTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.CreateAccountsWithSalesOpportunity();
    }

    @IsTest
    static void testAccountStrategy(){
        Id StrategicOpportunityRtId = Utility.getRecordTypeIdByDeveloperName('Opportunity', 'Strategic');
        Account acc = [ select id from Account where Name = 'Sales Area' limit 1 ];

        Account_Strategy__c aStrategy = new Account_Strategy__c();
        insert aStrategy;

        Opportunity startegicOppo = new Opportunity();
        startegicOppo.AccountId = acc.id;
        startegicOppo.RecordTypeId = StrategicOpportunityRtId;
        startegicOppo.AccountStrategy__c = aStrategy.id;
        startegicOppo.StatusPlaced__c = 'Placed';
        startegicOppo.PotentialImpact__c = 99;
        startegicOppo.Name = 'Strategic';
        startegicOppo.StageName = 'Proposal';
        startegicOppo.CloseDate = Date.today();
        insert startegicOppo;

        aStrategy = [ select id, NoPlacedObjectives__c, PotentialImpact__c from Account_Strategy__c where id = :aStrategy.id ];

        System.assertEquals(startegicOppo.PotentialImpact__c, aStrategy.PotentialImpact__c);
        System.assertEquals(1, aStrategy.NoPlacedObjectives__c);
    }

    @IsTest
    static void testAccountProspect(){
        Account acc = [ select id from Account where Name = 'Sales Area' limit 1 ];
        Id ProspectAccountRtId = Utility.getRecordTypeIdByDeveloperName('Account', SAP_Utility.Account_ProspectRT);
        acc.recordTypeId = ProspectAccountRtId;
        update acc;

        Opportunity oppo = [ select id from Opportunity where AccountId = :acc.id limit 1 ];

        oppo.StageName = 'Closed';

        Database.SaveResult sr = Database.update(oppo, false);

        System.assertEquals(false, sr.success);

/*System.assert(sr.getErrors())

   Prospect Account cannot be used*/

    }

    @IsTest
    static void testExRateChange(){
        Test.startTest();
        OpportunityLineItem oli = [ SELECT id, Quantity, BasePrice__c, VolumeTO__c, Product2Id, OpportunityId, Opportunity.ExchangeRate__c FROM OpportunityLineItem limit 1 ];
        oli.LogisticCost__c = 5;

        Opportunity oppo = new Opportunity();
        oppo.ExchangeRate__c = oli.Opportunity.ExchangeRate__c*2;
        oppo.id = oli.OpportunityId;

        try{
            update oli;
            update oppo;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();

        OpportunityLineItem updatedOli = [ SELECT id, Quantity, BasePrice__c, VolumeTO__c, Product2Id, OpportunityId, Opportunity.ExchangeRate__c, LogisticCost__c FROM OpportunityLineItem limit 1 ];


        //System.assertEquals(oli.BasePrice__c, updatedOli.BasePrice__c);

        //System.assertEquals(oli.LogisticCost__c, updatedOli.LogisticCost__c/2);

    }

}