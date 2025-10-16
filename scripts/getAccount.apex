Account acc = [
            SELECT Id, Name, SalesArea__r.SalesArea_LegalInformation__r.LegalTexts__c
            FROM Account
            // WHERE Id = '0019X0000149BUWQA2'
            WHERE Id = '0019X0000149DJYQA2'
        ];

System.debug('-----acc.SalesArea__r.SalesArea_LegalInformation__r.LegalTexts__c: ' + acc.SalesArea__r.SalesArea_LegalInformation__r.LegalTexts__c);
System.debug('-----acc.SalesArea__r.SalesArea_LegalInformation__c: ' + acc.SalesArea__r.SalesArea_LegalInformation__c);
System.debug('-----acc.SalesArea__c: ' + acc.SalesArea__c);