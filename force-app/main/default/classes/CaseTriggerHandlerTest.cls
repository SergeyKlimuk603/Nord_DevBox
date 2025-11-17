/****************************************************************************************************
* Class CaseTriggerHandlerTest
*
*   Create By   :  Andrei Pivavarchyk (mindsquare GmbH)
*   Create Date :  10.09.2025
*   Description  : Test class for the CaseTriggerHandler
*
*   Modification Log:
*   -------------------------------------------------------------------------------------------------
*   * Developer                             Date           Description
*   * -----------------------------------------------------------------------------------------------
*   * Andrei Pivavarchyk (mindsquare GmbH)  10.09.2025     Init version.
****************************************************************************************************/

@IsTest
public class CaseTriggerHandlerTest {
    private static Id CH1_ID, CH2_ID, CH3_ID, CH4_ID, GD_SHIP_TO_ID, BUYER_GROUP_ID;

    @TestSetup
    static void setupData() {
        Id rtSalesArea  = Utility.getRecordTypeIdByDeveloperName('Account', 'Sales_Area');
        Id rtBuyerGroup = Utility.getRecordTypeIdByDeveloperName('Account', 'BuyerGroup');

        Account buyerGroup = new Account(Name = 'Buyer Group A', RecordTypeId = rtBuyerGroup);
        insert buyerGroup;
        BUYER_GROUP_ID = buyerGroup.Id;

        Account gd = new Account(Name = 'GD ShipTo', CustomerAccountGroup__c = 'ZSSP');
        insert gd;
        GD_SHIP_TO_ID = gd.Id;

        Account ch1 = new Account(
                Name = 'CH1',
                RecordTypeId = rtSalesArea,
                BuyerGroup__c = BUYER_GROUP_ID,
                Division_Division__c = '10'
        );
        insert ch1; CH1_ID = ch1.Id;

        Account ch2 = new Account(
                Name = 'CH2',
                RecordTypeId = rtSalesArea,
                ParentId = CH1_ID,
                Division_Division__c = '10'
        );
        insert ch2; CH2_ID = ch2.Id;

        Account ch3 = new Account(
                Name = 'CH3',
                RecordTypeId = rtSalesArea,
                ParentId = CH2_ID,
                Division_Division__c = '10'
        );
        insert ch3; CH3_ID = ch3.Id;

        Account ch4 = new Account(
                Name = 'CH4',
                RecordTypeId = rtSalesArea,
                ParentId = CH3_ID,
                Division_Division__c = '10',
                GeneralDataAccount__c = GD_SHIP_TO_ID
        );
        insert ch4; CH4_ID = ch4.Id;
    }

    @IsTest
    static void test_MainProcessBefore_hierarchy_and_shipto() {
        Case c3 = new Case(Subject = 'C-CH3', AccountId = CH3_ID, Status = 'New');
        insert c3;
        c3 = [SELECT Parent_Account_Buyer_Group__c, CH1__c, CH2__c, CH3__c, ShipTo__c, SoldTo__c FROM Case WHERE Id = :c3.Id];
        System.assertEquals(BUYER_GROUP_ID, c3.Parent_Account_Buyer_Group__c);
        System.assertEquals(CH1_ID, c3.CH1__c);
        System.assertEquals(CH2_ID, c3.CH2__c);
        System.assertEquals(CH3_ID, c3.CH3__c);
        System.assertEquals(null,   c3.ShipTo__c);
        System.assertEquals(null,   c3.SoldTo__c);

        Case c4 = new Case(Subject = 'C-CH4', AccountId = CH4_ID, Status = 'New');
        insert c4;
        c4 = [SELECT CH1__c, CH2__c, CH3__c, ShipTo__c, SoldTo__c, Parent_Account_Buyer_Group__c FROM Case WHERE Id = :c4.Id];
        System.assertEquals(CH1_ID,       c4.CH1__c);
        System.assertEquals(CH2_ID,       c4.CH2__c);
        System.assertEquals(CH3_ID,       c4.CH3__c);
        System.assertEquals(GD_SHIP_TO_ID, c4.ShipTo__c);
        System.assertEquals(null,         c4.SoldTo__c);
        System.assertEquals(BUYER_GROUP_ID, c4.Parent_Account_Buyer_Group__c);
    }
}