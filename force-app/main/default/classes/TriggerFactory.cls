/**
 * @description         The purpose of this class is to work out which trigger handler needs to be called for
 *                      a trigger which is currently executing.
 */
public with sharing class TriggerFactory {
    /**
     * @description     Instantiates the correct handler for the sObject type being processed.
     * @param soType    The sObject type to instaniate the handler for
     * @return          Instance of a new trigger handler for the requested sObject type
     */
    private static TriggerHandler getHandler(Schema.sObjectType soType) {
        // add a triggerhandler here according to your need
        // Bypassing the trigger can be done with the setting of customsetting: Trigger_Settings__c
        // Bypass All, or per object (orgwide, per profile, or per user)

        if (!triggerSettings.Bypass_All_Triggers__c) {
            if (soType == OpportunityLineItem.sObjectType) {
                if (!BypassTrigger(OpportunityLineItem.sObjectType)) {
                    //return the triggerhandler for this sObjectType
                    return new OpportunityProductTriggerHandler();
                }
            }

            if (soType == Account.sObjectType) {
                if (!BypassTrigger(Account.sObjectType)) {
                    return new AccountTriggerHandler();
                }
            }

            if (soType == Opportunity.sObjectType) {
                if (!BypassTrigger(Opportunity.sObjectType)) {
                    return new OpportunityTriggerHandler();
                }
            }

            if (soType == xecm__BusinessObjectWorkspace__c.sObjectType) {
                if (!BypassTrigger(xecm__BusinessObjectWorkspace__c.sObjectType)) {
                    return new BusinessObjectWorkspaceTriggerHandler();
                }
            }
        } else {
            system.debug('#### Bypass All Triggers for: ' + runningUser.Name);
        }

        return new EmptyTriggerHandler();
    }

    /**
     * @description     Class which will be instanstiated if no handler can be located
     */
    private class EmptyTriggerHandler extends TriggerHandler {
    }

    /**
     * @description     Locates and instantiates the registered handler for an sObject.
     * @param soType    The sObject type to locate the handler for
     */
    public static void createHandler(Schema.sObjectType soType) {
        getHandler(soType).execute();
    }

    private static User runningUser {
        get {
            if (runningUser == null) {
                try {
                    runningUser = [SELECT Name FROM user WHERE id = :Userinfo.getUserId()];
                } catch (System.Exception qe) {
                    system.debug('#### Cannot Query User');
                }
            }
            return runningUser;
        }
        set;
    }

    private static Trigger_Settings__c triggerSettings {
        get {
            return Trigger_Settings__c.getInstance();
        }
        set;
    }

    private static boolean BypassTrigger(sObjectType sobjectType) {
        boolean bypass = false;
        try {
            bypass = (boolean) triggerSettings.get('Bypass ' + sobjectType);
        } catch (System.Exception qe) {
            system.debug('#### Bypass_Trigger Setting not set');
        }
        return bypass;
    }
}