/**
 * @File Name          : AccountTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : Roman Hnativ
 * @Group              : 
 * @Last Modified By   : Roman Hnativ
 * @Last Modified On   : 6/10/2020, 1:30:58 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/10/2020   Roman Hnativ     Initial Version
**/


@istest    
public class AccountTriggerHandlerTest {
    private static string ShipToParty_KUNNR = 'SHIP_TO';
    private static string SalesArea_KUNNR = 'SALES';
    private static string CustomerHirerarchy_KUNNR = 'CH01';

    public static string SalesArea_VKORG = '1000';
    public static string SalesArea_VTWEG = '10';
    public static string SalesArea_SPART = '10';

    @IsTest
    static void testInsert() {
        User u = TestDataFactory.createUser(true);
        Id newUserId = u.id;

        List<Account> accounts = new List<Account>();

        SalesArea_LegalInformation__c sa_legal = new SalesArea_LegalInformation__c();
        insert sa_legal;

        Sales_Area__c sa = new Sales_Area__c();
        sa.SAP_VKORG__c = SalesArea_VKORG;
        sa.SalesArea_LegalInformation__c = sa_legal.id;
        insert sa;

        Id CustomerHirerarchyRtId = Utility.getRecordTypeIdByDeveloperName('Account', SAP_Utility.Account_CustomerHirerarchyRT);
        Id SalesAreaRtId = Utility.getRecordTypeIdByDeveloperName('Account', SAP_Utility.Account_SalesAreaRT);
       
        Account customHirerarchy = new Account();
        customHirerarchy.SAP_KUNNR__c = CustomerHirerarchy_KUNNR;
        customHirerarchy.RecordTypeId = CustomerHirerarchyRtId;
        customHirerarchy.Name = 'Hirerarchy Account';
        customHirerarchy.CustomerAccountGroup__c = SAP_Utility.AccountGroup_SoldToParty;
        insert customHirerarchy;

     

        //check for accountshare
        List<AccountShare> beforeOwnerShares = [ select id from AccountShare where AccountId =:customHirerarchy.id and RowCause = 'Manual' ];
        system.assertEquals(0, beforeOwnerShares.size());

        Account salesArea = new Account();
        salesArea.SAP_KUNNR__c = SalesArea_KUNNR;
        salesArea.RecordTypeId = SalesAreaRtId;
        salesArea.Name = 'Sales Area';
        salesArea.Sales_Organization__c = SalesArea_VKORG;
        salesArea.Distribution_Channel__c = SalesArea_VTWEG;
        salesArea.Division_Division__c = SalesArea_SPART;
        salesArea.SAP_SalesArea_Key__c = SalesArea_KUNNR + '_' + SalesArea_VKORG + '_' + SalesArea_VTWEG + '_' + SalesArea_SPART;
        salesArea.SalesArea__c = sa.id;
        salesArea.GeneralDataAccount__c = customHirerarchy.id;
        salesArea.OwnerId = newUserId; //here we set new owner
        insert salesArea;

        //check for account share
        List<AccountShare> afterOwnerShares = [ select id from AccountShare where AccountId =:customHirerarchy.id and RowCause = 'Manual' ];
        //system.assertEquals(1, afterOwnerShares.size());
    }

    @IsTest
    static void testUpdate() {
        User u = TestDataFactory.createUser(true);
        Id newUserId = u.id;

        List<Account> accounts = new List<Account>();

        SalesArea_LegalInformation__c sa_legal = new SalesArea_LegalInformation__c();
        insert sa_legal;

        Sales_Area__c sa = new Sales_Area__c();
        sa.SAP_VKORG__c = SalesArea_VKORG;
        sa.SalesArea_LegalInformation__c = sa_legal.id;
        insert sa;

       Id CustomerHirerarchyRtId = Utility.getRecordTypeIdByDeveloperName('Account', SAP_Utility.Account_CustomerHirerarchyRT);
        Id SalesAreaRtId = Utility.getRecordTypeIdByDeveloperName('Account', SAP_Utility.Account_SalesAreaRT);

       
        Account salesArea = new Account();
        salesArea.SAP_KUNNR__c = SalesArea_KUNNR;
        salesArea.RecordTypeId = SalesAreaRtId;
        salesArea.Name = 'Sales Area';
        salesArea.Sales_Organization__c = SalesArea_VKORG;
        salesArea.Distribution_Channel__c = SalesArea_VTWEG;
        salesArea.Division_Division__c = SalesArea_SPART;
        salesArea.SAP_SalesArea_Key__c = SalesArea_KUNNR + '_' + SalesArea_VKORG + '_' + SalesArea_VTWEG + '_' + SalesArea_SPART;
        salesArea.SalesArea__c = sa.id;
        accounts.add(salesArea);

        Account customHirerarchy = new Account();
        customHirerarchy.SAP_KUNNR__c = CustomerHirerarchy_KUNNR;
        customHirerarchy.RecordTypeId = CustomerHirerarchyRtId;
        customHirerarchy.Name = 'Hirerarchy Account';
        customHirerarchy.CustomerAccountGroup__c = SAP_Utility.AccountGroup_SoldToParty;
        accounts.add(customHirerarchy);

        insert accounts;

        //check for accountshare
        List<AccountShare> beforeOwnerShares = [ select id from AccountShare where AccountId =:customHirerarchy.id and RowCause = 'Manual' ];
        system.assertEquals(0, beforeOwnerShares.size());

        salesArea.GeneralDataAccount__c = customHirerarchy.id;
        salesArea.OwnerId = newUserId; //here we set new owner
        update salesArea;

        //check for account share
        List<AccountShare> afterOwnerShares = [ select id from AccountShare where AccountId =:customHirerarchy.id and RowCause = 'Manual' ];
        //system.assertEquals(1, afterOwnerShares.size());
    }
}