@IsTest
private class CompetitorIntelControllerTest {

    @TestSetup
    static void setup() {
        String openStage = [SELECT ApiName FROM OpportunityStage WHERE IsActive = true AND IsClosed = false ORDER BY SortOrder LIMIT 1].ApiName;
        String wonStage = [SELECT ApiName FROM OpportunityStage WHERE IsActive = true AND IsWon = true LIMIT 1].ApiName;
        String lostStage = [SELECT ApiName FROM OpportunityStage WHERE IsActive = true AND IsClosed = true AND IsWon = false LIMIT 1].ApiName;
        Account customer = new Account(Name = 'Intel Agency', Account_Role__c = 'Customer');
        Account rival = new Account(Name = 'Rival Federal', Account_Role__c = 'Competitor');
        insert new List<Account>{ customer, rival };

        insert new List<Opportunity>{
            new Opportunity(Name = 'Open Below Floor', AccountId = customer.Id, StageName = openStage, CloseDate = Date.today().addMonths(3),
                Amount = 1000000, Contract_Type__c = 'Fixed Price', Estimated_Margin__c = 9, Incumbent__c = rival.Id),
            new Opportunity(Name = 'Won Against Rival', AccountId = customer.Id, StageName = wonStage, CloseDate = Date.today().addMonths(-2),
                Amount = 500000, Contract_Type__c = 'Fixed Price', Estimated_Margin__c = 12, Incumbent__c = rival.Id),
            new Opportunity(Name = 'Lost To Rival', AccountId = customer.Id, StageName = lostStage, CloseDate = Date.today().addMonths(-1),
                Amount = 800000, Contract_Type__c = 'Fixed Price', Estimated_Margin__c = 17, Incumbent__c = rival.Id,
                Lost_To__c = rival.Id, Loss_Reason__c = 'Price')
        };
    }

    @IsTest
    static void profilesTheIncumbentFromAnOpportunity() {
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = 'Open Below Floor'].Id;
        Test.startTest();
        CompetitorIntelController.Intel intel = CompetitorIntelController.getIntel(oppId);
        Test.stopTest();

        Assert.areEqual('Rival Federal', intel.competitorName);
        Assert.areEqual(1, intel.wins);
        Assert.areEqual(1, intel.losses);
        Assert.areEqual(500000, intel.bookingsWon);
        Assert.areEqual(800000, intel.bookingsLost);
        Assert.areEqual(12, intel.avgMarginWon);
        Assert.areEqual(17, intel.avgMarginLost);
        Assert.areEqual(1, intel.openDeals);
        Assert.areEqual(1000000, intel.openPipeline);
        Assert.areEqual('Price', intel.lossReasons[0].reason);
        Assert.areEqual(2, intel.recent.size());
        Assert.areEqual(9, intel.pursuitMargin, 'The open opportunity\'s own margin');
        Assert.areEqual(12, intel.pursuitFloor, 'Fixed Price floor');
    }

    @IsTest
    static void profilesACompetitorAccount() {
        Id rivalId = [SELECT Id FROM Account WHERE Name = 'Rival Federal'].Id;
        Test.startTest();
        CompetitorIntelController.Intel intel = CompetitorIntelController.getIntel(rivalId);
        Test.stopTest();

        Assert.areEqual(1, intel.losses);
        Assert.isNull(intel.pursuitMargin, 'No pursuit on a competitor\'s account page');
    }

    @IsTest
    static void returnsNothingWithoutACompetitor() {
        Id customerId = [SELECT Id FROM Account WHERE Name = 'Intel Agency'].Id;
        Opportunity noIncumbent = [SELECT Id FROM Opportunity WHERE Name = 'Open Below Floor'];
        noIncumbent.Incumbent__c = null;
        update noIncumbent;

        Assert.isNull(CompetitorIntelController.getIntel(customerId), 'A customer account is not profiled');
        Assert.isNull(CompetitorIntelController.getIntel(noIncumbent.Id), 'No incumbent, nothing to profile');
        Assert.isNull(CompetitorIntelController.getIntel(null));
    }
}
