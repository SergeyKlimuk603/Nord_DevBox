@isTest
/*
   fake handler to work with test covarage for generic trigger jandler
 */
private class TriggerHandlerTest {
    private static TriggerHandlerTest.TestHandler handler = new TriggerHandlerTest.TestHandler();
    private static String lastMethodCalled;

/***************************************
* unit tests
***************************************/

    // contexts tests

    @isTest
    static void testBeforeInsert() {

        handler.beforeInsert(null);
        System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }

    @isTest
    static void testBeforeUpdate() {
        handler.beforeUpdate(null, null);       
        System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
    }

    @isTest
    static void testBeforeDelete() {

        handler.beforeDelete(null);      
        System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
    }

    @isTest
    static void testAfterInsert() {
        handler.afterInsert(null);       
        System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
    }

    @isTest
    static void testAfterUpdate() {

        handler.afterUpdate(null, null);     
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
    }

    @isTest
    static void testAfterDelete() {

        handler.afterDelete(null);
        System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
    }

    @isTest
    static void testPreventRecursiveTrigger() {

        handler.preventRecursiveTrigger(true);
       // handler.execute();
    }


    

   
    private class TestHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newObjects){
            TriggerHandlerTest.lastMethodCalled = 'beforeInsert';
        }

        public override void  beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects) {
            TriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete(List<SObject> objects) {
            TriggerHandlerTest.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert(List<SObject> newObjects) {
            TriggerHandlerTest.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects) {
            TriggerHandlerTest.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete(List<SObject> objects) {
            TriggerHandlerTest.lastMethodCalled = 'afterDelete';
        }

    }

}