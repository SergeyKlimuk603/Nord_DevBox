@isTest
public class CaseTriggerHandlerTest {
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account 1';

    @TestSetup
    static void setup() {
        Account account1 = new Account(Name = PARENT_ACCOUNT_NAME);
        insert account1;
        Account account2 = new Account(Name = 'Test Account 2', ParentId = account1.Id);
        insert account2;
        Account account3 = new Account(Name = 'Test Account 3', ParentId = account2.Id);
        insert account3;
        Account account4 = new Account(Name = 'Test Account 4', ParentId = account3.Id);
        insert account4;
    }

    @IsTest
    static void testInsert() {
        Account parentAccount = getParentAccount();
        System.debug('-----parentAccount: ' + parentAccount);

    }

    private static Account getParentAccount() {
        return [
            SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId, BuyerGroup__c
            FROM Account
            WHERE Name = :PARENT_ACCOUNT_NAME
            LIMIT 1
        ];
    }
    
}