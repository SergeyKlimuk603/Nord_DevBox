/**
 * @File Name          : OpportunityTriggerHandler.cls
 * @Description        :
 * @Author             : Roman Hnativ
 * @Group              :
 * @Last Modified By   : Roman Hnativ
 * @Last Modified On   : 6/30/2020, 10:33:08 AM
 * @Modification Log   :
 * Ver       Date            Author                         Modification
 * 1.0    6/23/2020   Roman Hnativ     Initial Version
 **/
public class OpportunityTriggerHandler extends TriggerHandler {

    Id StrategicOpportunityRtId = Utility.getRecordTypeIdByDeveloperName('Opportunity', 'Strategic');
    Id SalesOpportunityRtId = Utility.getRecordTypeIdByDeveloperName('Opportunity', 'RenewalBusiness');
    Id RetailOpportunityRtId = Utility.getRecordTypeIdByDeveloperName('Opportunity', 'Retail_Pricing');
    Id WorldMarketPricingOpportunityRtId = Utility.getRecordTypeIdByDeveloperName('Opportunity', 'World_Market_Pricing');
    Id ProspectAccountRtId = Utility.getRecordTypeIdByDeveloperName('Account', SAP_Utility.Account_ProspectRT);

    private static final String FREIGHT_VISIBILITY_HIDDEN = 'ZFHD';
    private static final String SERVICE_FEE_VISIBILITY_HIDDEN = 'ZLSH';

    public override void beforeInsert(List<SObject> newObjects) {
        set<id> accountIds = new set<id>();

        for (SObject obj : newObjects) {
            Opportunity opp = (Opportunity) obj;

            if (opp.recordTypeId == SalesOpportunityRtId) {
                accountIds.add(opp.AccountId);
            }

            if (opp.TemplateLanguage__c != null && !(opp.isClone())) {
                if (opp.Terms_and_Conditions_Closing_Sentence__c == null) {
                    opp.Terms_and_Conditions_Closing_Sentence__c = getlbl_Quote_Closing_Sentence1(opp);
                }
                if (opp.Offer_Appreciation_Closing_Sentence__c == null) {
                    opp.Offer_Appreciation_Closing_Sentence__c = getlbl_Quote_Closing_Sentence2(opp);
                }
            }
        }

        /*
            Industry → Industry
            Retail → Retail 
            Everything else → Industry, but should not happen
         */

        map<id, Account> accounts = new map<id, Account>([select id, SalesArea__r.id, SalesArea__r.DistributionChannelText__c from account where id = :accountIds]);

        for (SObject obj : newObjects) {
            Opportunity opp = (Opportunity) obj;

            if (opp.RecordTypeId == SalesOpportunityRtId) {
                opp.BaseReference__c = 'Industry';
                Account acc = accounts.get(opp.AccountId);
                if (acc != null && acc.SalesArea__r != null) {
                    if (acc.SalesArea__r.DistributionChannelText__c == 'Retail') {
                        opp.BaseReference__c = 'Retail';
                    }
                }
            } else if(opp.RecordTypeId == RetailOpportunityRtId) {
                opp.BaseReference__c = 'Retail';
            }
            if (opp != null && (opp.ExchangeRate__c == 1.0) || (opp.ExchangeRate__c == 0.0)) {
                opp.ExchangeRate__c = PricingUtils.GetConversionRate(opp.CurrencyIsoCode).ConversionRate;
            }
        }

        mainProcessBeforeInsert(newObjects);

    }

    public override void afterInsert(List<SObject> newObjects) {
        set<id> accountStrategyIds = new set<id>();

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (SObject obj : newObjects) {
            Opportunity opp = (Opportunity) obj;

            if (opp.recordTypeId == StrategicOpportunityRtId) {
                if (opp.AccountStrategy__c != null) {
                    accountStrategyIds.add(opp.AccountStrategy__c);
                }
            }

            opportunitiesToUpdate.add(new Opportunity(
                Id = opp.Id,
                Record_Id_for_Clone__c = opp.Id
            ));

            // if (opp.recordTypeId == SalesOpportunityRtId) {
            //  if (opp.isClone() )
            //  {
            //      id sourceId = opp.getCloneSourceId();
            //      sourceMap.put(opp.id, sourceId);
            //  }
            // }
        }

        update opportunitiesToUpdate;

        //Map<Id, List<OpportunityLineItem>> opportunityLineItems = new Map<Id, List<OpportunityLineItem>>();
        Map<Id, List<Opportunity_ShipTo_Junction__c>> opportunityShipToJunctions = new Map<Id, List<Opportunity_ShipTo_Junction__c>>();

        //List<OpportunityLineItem> opportunityLineItemsToInsert = new List<OpportunityLineItem>();
        List<Opportunity_ShipTo_Junction__c> opportunityShipToJunctionsToInsert = new List<Opportunity_ShipTo_Junction__c>();

        for (Opportunity opportunity : (List<Opportunity>)newObjects) {
            if (opportunity.Record_Id_for_Clone__c != null) {
                //opportunityLineItems.put(opportunity.Record_Id_for_Clone__c, null);
                opportunityShipToJunctions.put(opportunity.Record_Id_for_Clone__c, null);
            }
        }

        /*Set<Id> opportunityLineItemsKeySet = opportunityLineItems.keySet();
        opportunityLineItems = new Map<Id, List<OpportunityLineItem>>();
        for (OpportunityLineItem opportunityLineItem : Database.query('SELECT ' + String.join(new List<String>(OpportunityLineItem.getSObjectType().getDescribe().fields.getMap().keySet()), ',') + ' FROM OpportunityLineItem WHERE OpportunityId IN :opportunityLineItemsKeySet')) {
            if (!opportunityLineItems.containsKey(opportunityLineItem.OpportunityId)) {
                opportunityLineItems.put(opportunityLineItem.OpportunityId, new List<OpportunityLineItem>());
            }

            opportunityLineItems.get(opportunityLineItem.OpportunityId).add(opportunityLineItem);
        }*/

        Set<Id> opportunityShipToJunctionsKeySet = opportunityShipToJunctions.keySet();
        opportunityShipToJunctions = new Map<Id, List<Opportunity_ShipTo_Junction__c>>();
        for (Opportunity_ShipTo_Junction__c opportunityShipToJunction : [
            SELECT Id, ShipTo__c, Opportunity__c
            FROM Opportunity_ShipTo_Junction__c
            WHERE Opportunity__c IN :opportunityShipToJunctionsKeySet
        ]) {
            if (!opportunityShipToJunctions.containsKey(opportunityShipToJunction.Opportunity__c)) {
                opportunityShipToJunctions.put(opportunityShipToJunction.Opportunity__c, new List<Opportunity_ShipTo_Junction__c>());
            }

            opportunityShipToJunctions.get(opportunityShipToJunction.Opportunity__c).add(opportunityShipToJunction);
        }

        for (Opportunity opportunity : (List<Opportunity>)newObjects) {
            if (opportunity.Record_Id_for_Clone__c != null) {
                /*if (opportunityLineItems.containsKey(opportunity.Record_Id_for_Clone__c)) {
                    for (OpportunityLineItem opportunityLineItem : opportunityLineItems.get(opportunity.Record_Id_for_Clone__c)) {
                        OpportunityLineItem newOpportunityLineItem = opportunityLineItem.clone(false, true);
                        newOpportunityLineItem.OpportunityId = opportunity.Id;
                        newOpportunityLineItem.TotalPrice = null;
                        opportunityLineItemsToInsert.add(newOpportunityLineItem);
                    }
                }*/

                if (opportunityShipToJunctions.containsKey(opportunity.Record_Id_for_Clone__c)) {
                    for (Opportunity_ShipTo_Junction__c opportunityShipToJunction : opportunityShipToJunctions.get(opportunity.Record_Id_for_Clone__c)) {
                        Opportunity_ShipTo_Junction__c newOpportunityShipToJunction = opportunityShipToJunction.clone(false, true);
                        newOpportunityShipToJunction.Opportunity__c = opportunity.Id;
                        opportunityShipToJunctionsToInsert.add(newOpportunityShipToJunction);
                    }
                }
            }
        }

        insert opportunityShipToJunctionsToInsert;
//        insert opportunityLineItemsToInsert;

        recalculateStrategySummary(accountStrategyIds);
    }

    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects) {
        map<id, SObject> oldObjectMap = new map<id, SObject>(oldObjects);
        set<id> accountIds = new set<id>();
        set<id> checkForProspect = new set<id>();
        set<string> validationStatus = new set<string>();
        validationStatus.add('Contracting');
        validationStatus.add('Closed');

        for (SObject obj : newObjects) {
            Opportunity opp = (Opportunity) obj;
            if (opp.recordTypeId == SalesOpportunityRtId) {
                Opportunity oldOpp = (Opportunity) oldObjectMap.get(opp.Id);

                if ((oldOpp.StageName != opp.StageName) && validationStatus.contains(opp.StageName)) {
                    checkForProspect.add(opp.Id);
                    accountIds.add(opp.AccountId);
                }
            }
        }

        if (accountIds.size() > 0) {
            Map<ID, Account> accountMap = new Map<ID, Account>([SELECT Id, Name, RecordTypeId FROM Account where id in:accountIds]);

            AggregateResult[] groupedOpportunityLineItems = [select opportunityid, count(id) from OpportunityLineItem where opportunityid in :checkForProspect and (SoldTo__r.Recordtypeid = :ProspectAccountRtId or ShipTo__r.Recordtypeid = :ProspectAccountRtId or BillTo__r.Recordtypeid = :ProspectAccountRtId) group by opportunityid];
            set<id> OpportunitiesWithProspectOLI = new set<id>();

            for (AggregateResult ar : groupedOpportunityLineItems) {

                OpportunitiesWithProspectOLI.add((Id) ar.get('opportunityid'));

            }

            for (SObject obj : newObjects) {
                Opportunity opp = (Opportunity) obj;

                if (checkForProspect.contains(opp.id)) {

                    if (accountMap.get(opp.accountId).RecordTypeId == ProspectAccountRtId) {
                        opp.addError('Prospect Account cannot be used at this stage');
                    }

                    if (OpportunitiesWithProspectOLI.contains(opp.id)) {
                        opp.addError('Prospect Account cannot be used in Opportunity Products at this stage');
                    }
                }
            }

        }

    }

    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects) {
        set<id> accountStrategyIds = new set<id>();
        //  set<id> recalculateOLI = new set<id>();
        map<id, SObject> oldObjectMap = new map<id, SObject>(oldObjects);
        Map<id, RecalculateXrate> recalculateRateMap = new Map<id, RecalculateXrate>();

        List<Opportunity> opportunitiesToUpdateLineItems = new List<Opportunity>();

        for (SObject obj : newObjects) {
            Opportunity opp = (Opportunity) obj;
            Opportunity oldOpp = (Opportunity) oldObjectMap.get(opp.Id);

            if (opp.recordTypeId == StrategicOpportunityRtId) {
                if (opp.AccountStrategy__c != oldOpp.AccountStrategy__c) {
                    accountStrategyIds.add(opp.AccountStrategy__c);
                }

                if (opp.AccountStrategy__c != null) {
                    //here we check for changedfields

                    if (opp.PotentialImpact__c != oldOpp.PotentialImpact__c) {
                        accountStrategyIds.add(opp.AccountStrategy__c);
                    }

                    if (opp.RealizedImpact__c != oldOpp.RealizedImpact__c) {
                        accountStrategyIds.add(opp.AccountStrategy__c);
                    }

                    if (opp.ExpectedImpact__c != oldOpp.ExpectedImpact__c) {
                        accountStrategyIds.add(opp.AccountStrategy__c);
                    }

                    if (opp.StatusPlaced__c != oldOpp.StatusPlaced__c) {
                        accountStrategyIds.add(opp.AccountStrategy__c);
                    }

                    if (opp.StatusAchieved__c != oldOpp.StatusAchieved__c) {
                        accountStrategyIds.add(opp.AccountStrategy__c);
                    }
                }
            }

            if (opp.recordTypeId == SalesOpportunityRtId) {
                if (oldOpp.ExchangeRate__c != opp.ExchangeRate__c) {
                    // recalculateOLI.add(opp.id);

                    RecalculateXrate rxr = new RecalculateXrate();
                    rxr.newId = opp.id;
                    rxr.oldId = oldOpp.id;
                    rxr.newRate = opp.ExchangeRate__c;
                    rxr.oldRate = oldOpp.ExchangeRate__c;
                    recalculateRateMap.put(rxr.newId, rxr);
                }

            }

            if (opp.Bonus_1__c != oldOpp.Bonus_1__c || opp.Bonus_2__c != oldOpp.Bonus_2__c || opp.Bonus_3__c != oldOpp.Bonus_3__c ||
                opp.Bonus_4__c != oldOpp.Bonus_4__c || opp.Bonus_5__c != oldOpp.Bonus_5__c || opp.Bonus_6__c != oldOpp.Bonus_6__c) {
                opportunitiesToUpdateLineItems.add(opp);
            }
        }

        recalculateStrategySummary(accountStrategyIds);

        recalculateProductPricing(recalculateRateMap);

        if (!opportunitiesToUpdateLineItems.isEmpty()) {
            List<OpportunityLineItem> opportunityLineItemsToUpdate = [
                SELECT Id, Bonus_1__c, Bonus_2__c, Bonus_3__c, Bonus_4__c, Bonus_5__c, Bonus_6__c, UnitPrice, Quantity, OpportunityId, n_n_Price__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN :opportunitiesToUpdateLineItems
            ];

            OpportunityProductTriggerHandler.recalculateDiscountFromBonuses(opportunityLineItemsToUpdate);

            update opportunityLineItemsToUpdate;
        }

        MonthlyVolumeService.createMonthlyVolumes(new Map<Id, Opportunity>((List<Opportunity>)newObjects), new Map<Id, Opportunity>((List<Opportunity>)oldObjects));
    }

    private static void recalculateProductPricing(Map<id, RecalculateXrate> recalculateMap) {
        set<id> recalculateOLI = recalculateMap.keySet();

        if (recalculateOLI.size() > 0) {
            Set<Id> productIds = new Set<Id>();
            List<OpportunityLineItem> recalculateItems = [
                    select id, ShipTo__c, Rebate__c,
                            OpportunityId, Product2Id, MandatePriceCreation__c, LogisticCost__c,
                            Tactical__c, ServiceFee__c, Discount__c, SGA__c, Sourcing_Country__c,
                            initialMarketSurcharge__c, initialCategorySurcharge__c, initialProductSurcharge__c, initialFixedPrice__c,
                            MarketSpecificPrice__c, BasePrice__c from opportunitylineitem where opportunityid in :recalculateOLI
            ];

            for (OpportunityLineItem oli : recalculateItems) {
                productIds.add(oli.Product2Id);

                RecalculateXrate xrate = recalculateMap.get(oli.opportunityid);
                decimal crossRate = xrate.newRate / xrate.oldRate;

                if (oli.LogisticCost__c != null) {
                    oli.LogisticCost__c = oli.LogisticCost__c * crossRate;
                }
                if (oli.Tactical__c != null) {
                    oli.Tactical__c = oli.Tactical__c * crossRate;
                }
                if (oli.ServiceFee__c != null) {
                    oli.ServiceFee__c = oli.ServiceFee__c * crossRate;
                }
                if (oli.Discount__c != null) {
                    oli.Discount__c = oli.Discount__c * crossRate;
                }
                /*  if (oli.Rebate__c!=null)
                    {
                        oli.Rebate__c = oli.Rebate__c*crossRate;
                    }*/
            }

            OpportunityProductTriggerHandler.recalculatePrices(recalculateItems, productIds);

            update recalculateItems;
        }
    }

    private static void recalculateStrategySummary(set<id> accountStrategyIds) {
        if (accountStrategyIds.size() > 0) {
            AggregateResult[] groupedResultTotals = [SELECT AccountStrategy__c, count(Id) c, sum(PotentialImpact__c) pi, sum(RealizedImpact__c) ri, sum(ExpectedImpact__c) ei FROM Opportunity where AccountStrategy__c in :accountStrategyIds group by AccountStrategy__c];
            map<Id, Account_Strategy__c> updateMap = new map<Id, Account_Strategy__c>();
            for (AggregateResult ar : groupedResultTotals) {
                Account_Strategy__c aStrategy = new Account_Strategy__c();
                aStrategy.Id = (Id) ar.get('AccountStrategy__c');
                aStrategy.NoObjectives__c = (decimal) ar.get('c');
                aStrategy.PotentialImpact__c = (decimal) ar.get('pi');
                aStrategy.RealizedImpact__c = (decimal) ar.get('ri');
                aStrategy.ExpectedImpact__c = (decimal) ar.get('ei');
                updateMap.put(aStrategy.Id, aStrategy);
            }

            AggregateResult[] groupedResultPlaced = [SELECT AccountStrategy__c, count(Id) c FROM Opportunity where AccountStrategy__c in :accountStrategyIds and StatusPlaced__c = 'Placed' group by AccountStrategy__c];
            for (AggregateResult ar : groupedResultPlaced) {
                Account_Strategy__c aStrategy = updateMap.get((id) ar.get('AccountStrategy__c'));
                aStrategy.NoPlacedObjectives__c = (decimal) ar.get('c');
            }

            AggregateResult[] groupedResultArchived = [SELECT AccountStrategy__c, count(Id) c FROM Opportunity where AccountStrategy__c in :accountStrategyIds and StatusAchieved__c = 'Placed' group by AccountStrategy__c];
            for (AggregateResult ar : groupedResultArchived) {
                Account_Strategy__c aStrategy = updateMap.get((id) ar.get('AccountStrategy__c'));
                aStrategy.NoAchievedObjectives__c = (decimal) ar.get('c');
            }

            update updateMap.values();

        }
    }

    public String getlbl_Quote_Closing_Sentence1(Opportunity opportunityRecord) {
        return ContractLabelTranslations.GetLabel('lbl_Quote_Closing_Sentence1', opportunityRecord.TemplateLanguage__c);
    }
    public String getlbl_Quote_Closing_Sentence2(Opportunity opportunityRecord) {
        return ContractLabelTranslations.GetLabel('lbl_Quote_Closing_Sentence2', opportunityRecord.TemplateLanguage__c);
    }

    private static void mainProcessBeforeInsert(List<Opportunity> opportunities) {
        if (opportunities == null || opportunities.isEmpty() || oldOpportunitiesMap == null || oldOpportunitiesMap.isEmpty()) return;

        for (Opportunity opportunity : opportunities) {
            setDefaultVisibility(opportunities);
            setContractToNew(opportunities);
        }
    }

    private static void mainProcessAfterInsert(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
        if (opportunities == null || opportunities.isEmpty()) return;

    }

    private static void mainProcessBeforeUpdate(List<Opportunity> opportunities) {
        if (opportunities == null || opportunities.isEmpty()) return;

    }

    private static void mainProcessAfterUpdate(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
        if (opportunities == null || opportunities.isEmpty() || oldOpportunitiesMap == null || oldOpportunitiesMap.isEmpty()) return;

    }

    private static Opportunity setDefaultVisibility(Opportunity opportunity) {
        if (opportunity == null) return null;

        if (opportunity.RecordTypeId == WorldMarketPricingOpportunityRtId) {
            opportunity.FreightVisibility__c = FREIGHT_VISIBILITY_HIDDEN;
            opportunity.ServiceFeeVisibility__c = SERVICE_FEE_VISIBILITY_HIDDEN;
        }

        return opportunity;
    }

    private static Opportunity setContractToNew(Opportunity opportunity) {
        if (opportunity == null) return null;

        if (opportunity.RecordTypeId == SalesOpportunityRtId) {
            opportunity.ContractStatus__c = 'New Contract';
            opportunity.ContractTemplateJSON__c = '""';
        }

        return opportunity;
    }

    public class RecalculateXrate {
        public Id newId;
        public Id oldId;
        public Decimal newRate;
        public Decimal oldRate;
    }

}