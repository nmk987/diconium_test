@IsTest
public with sharing class TerritoryTriggerHandlerTest {
    @TestSetup
    private static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'SystemAdministrator' LIMIT 1];

        List<User> testUsers = new List<User>{
            new User(
                Alias = '1',
                Email='testuser1@testorg.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName=System.now().format('yyyyMMddhhmmss') + '1@testorg.com'
            ),
            new User(
                Alias = '2',
                Email='testuser2@testorg.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName=System.now().format('yyyyMMddhhmmss') + '2@testorg.com'
            )
        };
        insert testUsers;
    }

    @IsTest
    private static void updateRelatedRecordsWithNewOwner_Test(){
        List<User> testUsers = [SELECT Id FROM User WHERE Alias IN ('1','2') ORDER BY Alias ASC];
        Territory__c testTerritory = new Territory__c(
            Name = '123456',
            OwnerId = testUsers.get(0).Id
        );

        insert testTerritory;

        Account testAccount = new Account(Name = 'TestAccount', BillingPostalCode = '123456');
        insert testAccount;

        List<Contact> testContacts = new List<Contact>{
            new Contact(
                AccountId = testAccount.Id,
                LastName = 'test'
            ),
            new Contact(
                AccountId = testAccount.Id,
                LastName = 'test'
            )
        };
        insert testContacts;

        List<Opportunity> testOpportunities = new List<Opportunity>{
            new Opportunity(
                AccountId = testAccount.Id,
                Name = 'test',
                StageName = 'Test Name',
                CloseDate = System.now().addDays(1).date()
            ),
            new Opportunity(
                AccountId = testAccount.Id,
                Name = 'test',
                StageName = 'Test Name',
                CloseDate = System.now().addDays(1).date()
            )
        };
        insert testOpportunities;

        testTerritory.OwnerId = testUsers.get(1).Id;
        update testTerritory;

        List<Account> testAccounts = [SELECT Id, OwnerId FROM Account LIMIT 2];
        testContacts = [SELECT Id, OwnerId FROM Contact WHERE AccountId =:testAccount.Id LIMIT 3];
        testOpportunities = [SELECT Id, OwnerId FROM Opportunity WHERE AccountId =:testAccount.Id LIMIT 3];

        System.assertEquals(1, testAccounts.size());
        System.assertEquals(2, testContacts.size());
        System.assertEquals(2, testOpportunities.size());

        System.assertEquals(testUsers.get(1).Id, testAccounts.get(0).OwnerId);

        System.assertEquals(testUsers.get(1).Id, testContacts.get(0).OwnerId);
        System.assertEquals(testUsers.get(1).Id, testContacts.get(1).OwnerId);

        System.assertEquals(testUsers.get(1).Id, testOpportunities.get(0).OwnerId);
        System.assertEquals(testUsers.get(1).Id, testOpportunities.get(1).OwnerId);
    }

    @IsTest
    private static void assignThreeUsers(){
        List<User> testUsers = [SELECT Id FROM User LIMIT 3];

        List<Territory__c> testTerritories = new List<Territory__c>();

        for(User user : testUsers){
            testTerritories.add(
                new Territory__c(
                    Name = '123456',
                    OwnerId = user.Id
                )
            );
        }

        Boolean isSuccess = true;
        try{
            insert testTerritories;
        }catch (Exception e){
            isSuccess = false;
        }

        System.assert(isSuccess);
    }

    @IsTest
    private static void assignMoreThenThreeUsers(){
        List<User> testUsers = [SELECT Id FROM User LIMIT 4];

        List<Territory__c> testTerritories = new List<Territory__c>();

        for(User user : testUsers){
            testTerritories.add(
                new Territory__c(
                    Name = '123456',
                    OwnerId = user.Id
                )
            );
        }

        Boolean isSuccess = false;
        try{
            insert testTerritories;
        }catch (Exception e){
            isSuccess = e.getMessage().contains('It is not allowed to assign more then 3 sales representatives to the one zip code');
        }

        System.assert(isSuccess, 'Validation must be appeared during DML');
    }
}