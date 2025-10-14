@IsTest
private class VirtualTriggerHandler_Test {
    private static final String TRIGGER_CONTEXT_ERROR = VirtualTriggerHandler.errorOutsideTriggerContext;

    private static String lastMethodCalled;

    private static final VirtualTriggerHandler_Test.TestHandler handler;

    static {
        handler = new VirtualTriggerHandler_Test.TestHandler();
        // override its internal trigger detection
        handler.isTriggerExecuting = true;
    }

    /***************************************
     * unit tests
     ***************************************/

    // contexts tests

    @IsTest
    static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }

    @IsTest
    static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
    }

    @IsTest
    static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
    }

    @IsTest
    static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
    }

    @IsTest
    static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
    }

    @IsTest
    static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
    }

    @IsTest
    static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
    }

    @IsTest
    static void testNonTriggerContext() {
        try {
            handler.run();
            System.assert(false, 'the handler ran but should have thrown');
        } catch (VirtualTriggerHandler.VirtualTriggerHandlerException te) {
            System.assertEquals(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
        } catch (Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    // test bypass api

    @IsTest
    static void testBypassAPI() {
        afterUpdateMode();

        // test a bypass by string and run handler
        VirtualTriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
        System.assertEquals(true, VirtualTriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        System.assert(!VirtualTriggerHandler.bypassList().isEmpty());
        resetTest();

        // clear that bypass and run handler
        VirtualTriggerHandler.clearBypass('TestHandler');
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        System.assertEquals(
            false,
            VirtualTriggerHandler.isBypassed('TestHandler'),
            'test handler should not be bypassed'
        );
        resetTest();

        // test a re-bypass by list and run handler
        VirtualTriggerHandler.bypass(new List<String>{ 'TestHandler' });
        handler.run();
        System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
        System.assertEquals(true, VirtualTriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        // clear that bypass and run handler
        VirtualTriggerHandler.clearBypass(new List<String>{ 'TestHandler' });
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        System.assertEquals(
            false,
            VirtualTriggerHandler.isBypassed('TestHandler'),
            'test handler should not be bypassed'
        );
        resetTest();

        // test a bypass and run handler
        VirtualTriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
        System.assertEquals(true, VirtualTriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();

        // clear all bypasses and run handler
        VirtualTriggerHandler.clearAllBypasses();
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        System.assertEquals(
            false,
            VirtualTriggerHandler.isBypassed('TestHandler'),
            'test handler should not be bypassed'
        );
        resetTest();

        // bypass everything
        VirtualTriggerHandler.bypassAll();
        handler.run();
        System.assert(VirtualTriggerHandler.bypassedHandlers.isEmpty());
        System.assert(VirtualTriggerHandler.globalBypass);
        resetTest();

        VirtualTriggerHandler.bypassAll();
        handler.run();
        System.assertEquals(true, VirtualTriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        System.assert(!VirtualTriggerHandler.bypassList().isEmpty());
        VirtualTriggerHandler.clearAllBypasses();
        System.assert(VirtualTriggerHandler.bypassList().isEmpty());
    }

    // Test and show limits
    @IsTest
    static void testBeforeInsertWithLimits() {
        beforeInsertMode();
        VirtualTriggerHandler.showLimits(false);
        VirtualTriggerHandler.showLimits();
        handler.run();
        System.assert(VirtualTriggerHandler.showLimits);
        VirtualTriggerHandler.getLoopCount('TestHandler');
        System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }

    // instance method tests

    @IsTest
    static void testLoopCount() {
        beforeInsertMode();

        // set the max loops to 2
        handler.setMaxLoopCount(2);

        // run the handler twice
        handler.run();
        handler.run();

        System.assertEquals(2, VirtualTriggerHandler.getLoopCount('TestHandler'));

        // clear the tests
        resetTest();

        try {
            // try running it. This should exceed the limit.
            handler.run();
            System.assert(false, 'the handler should throw on the 3rd run when maxloopcount is 3');
        } catch (VirtualTriggerHandler.VirtualTriggerHandlerException te) {
            // we're expecting to get here
            System.assertEquals(null, lastMethodCalled, 'last method should be null');
        } catch (Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }

        // clear the tests
        resetTest();

        // now clear the loop count
        handler.clearMaxLoopCount();

        try {
            // re-run the handler. We shouldn't throw now.
            handler.run();
            System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
        } catch (VirtualTriggerHandler.VirtualTriggerHandlerException te) {
            System.assert(false, 'running the handler after clearing the loop count should not throw');
        } catch (Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }

    @IsTest
    static void testLoopCountClass() {
        VirtualTriggerHandler.LoopCount lc = new VirtualTriggerHandler.LoopCount();
        System.assertEquals(5, lc.getMax(), 'max should be five on init');
        System.assertEquals(0, lc.getCount(), 'count should be zero on init');

        lc.increment();
        System.assertEquals(1, lc.getCount(), 'count should be 1');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');

        lc.increment();
        lc.increment();
        lc.increment();
        lc.increment();
        System.assertEquals(5, lc.getCount(), 'count should be 5');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');

        lc.increment();
        System.assertEquals(6, lc.getCount(), 'count should be 6');
        System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
    }

    // private method tests

    @IsTest
    static void testGetHandlerName() {
        System.assertEquals('TestHandler', handler.getHandlerName(), 'handler name should match class name');
    }

    // test virtual methods

    @IsTest
    static void testVirtualMethods() {
        VirtualTriggerHandler h = new VirtualTriggerHandler();
        h.beforeInsert();
        h.beforeUpdate();
        h.beforeDelete();
        h.afterInsert();
        h.afterUpdate();
        h.afterDelete();
        h.afterUndelete();
    }

    /***************************************
     * testing utilities
     ***************************************/

    private static void resetTest() {
        lastMethodCalled = null;
    }

    // modes for testing

    private static void beforeInsertMode() {
        handler.setTriggerContext(System.TriggerOperation.BEFORE_INSERT, true);
    }

    private static void beforeUpdateMode() {
        handler.setTriggerContext(System.TriggerOperation.BEFORE_UPDATE, true);
    }

    private static void beforeDeleteMode() {
        handler.setTriggerContext(System.TriggerOperation.BEFORE_DELETE, true);
    }

    private static void afterInsertMode() {
        handler.setTriggerContext(System.TriggerOperation.AFTER_INSERT, true);
    }

    private static void afterUpdateMode() {
        handler.setTriggerContext(System.TriggerOperation.AFTER_UPDATE, true);
    }

    private static void afterDeleteMode() {
        handler.setTriggerContext(System.TriggerOperation.AFTER_DELETE, true);
    }

    private static void afterUndeleteMode() {
        handler.setTriggerContext(System.TriggerOperation.AFTER_UNDELETE, true);
    }

    // test implementation of the VirtualTriggerHandler

    private class TestHandler extends VirtualTriggerHandler {
        public override void beforeInsert() {
            VirtualTriggerHandler_Test.lastMethodCalled = 'beforeInsert';
        }

        public override void beforeUpdate() {
            VirtualTriggerHandler_Test.lastMethodCalled = 'beforeUpdate';
        }

        public override void beforeDelete() {
            VirtualTriggerHandler_Test.lastMethodCalled = 'beforeDelete';
        }

        public override void afterInsert() {
            VirtualTriggerHandler_Test.lastMethodCalled = 'afterInsert';
        }

        public override void afterUpdate() {
            VirtualTriggerHandler_Test.lastMethodCalled = 'afterUpdate';
        }

        public override void afterDelete() {
            VirtualTriggerHandler_Test.lastMethodCalled = 'afterDelete';
        }

        public override void afterUndelete() {
            VirtualTriggerHandler_Test.lastMethodCalled = 'afterUndelete';
        }
    }
}