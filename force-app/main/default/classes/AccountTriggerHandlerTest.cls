@IsTest
public with sharing class AccountTriggerHandlerTest {
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

        List<Territory__c> testTerritories = new List<Territory__c>{
            new Territory__c(
                Name = '123456',
                OwnerId = testUsers.get(0).Id
            ),
            new Territory__c(
                Name = '654321',
                OwnerId = testUsers.get(1).Id
            )
        };

        insert testTerritories;
    }

    @IsTest
    private static void createAccountWithoutTerritory_Test() {
        Account testAccount = new Account(Name = 'TestAccount', BillingPostalCode = '111111');
        insert testAccount;

        List<Account> testAccounts = [SELECT Id, OwnerId, Territory__c FROM Account LIMIT 2];
        System.assertEquals(1, testAccounts.size());
        System.assertEquals(UserInfo.getUserId(), testAccounts.get(0).OwnerId);
        System.assertEquals(null, testAccounts.get(0).Territory__c);
    }

    @IsTest
    private static void assignAccountOwner_Test(){
        List<User> testUsers = [SELECT Id FROM User WHERE Alias IN ('1','2') ORDER BY Alias ASC];

        List<Territory__c> testTerritories = [SELECT Id FROM Territory__c];

        Account testAccount = new Account(Name = 'TestAccount', BillingPostalCode = '123456');
        insert testAccount;

        List<Account> testAccounts = [SELECT Id, OwnerId, Territory__c FROM Account LIMIT 2];

        System.assertEquals(1, testAccounts.size());
        System.assertEquals(testTerritories.get(0).Id, testAccounts.get(0).Territory__c);
        System.assertEquals(testUsers.get(0).Id, testAccounts.get(0).OwnerId);

        testAccount.BillingPostalCode = '654321';
        update testAccount;

        testAccounts = [SELECT Id, OwnerId, Territory__c FROM Account LIMIT 2];
        System.assertEquals(1, testAccounts.size());
        System.assertEquals(testTerritories.get(1).Id, testAccounts.get(0).Territory__c);
        System.assertEquals(testUsers.get(1).Id, testAccounts.get(0).OwnerId);
    }

    @IsTest
    private static void assignOwnerToChildContacts_Test(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser1@testorg.com'];

        List<Territory__c> testTerritories = [SELECT Id FROM Territory__c];

        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;

        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i < 2; i++){
            testContacts.add(
                new Contact(
                    OwnerId = UserInfo.getUserId(),
                    LastName = 'Test name',
                    Email = 'test@test.com',
                    AccountId = testAccount.Id
                )
            );
        }

        insert testContacts;

        testAccount.BillingPostalCode = '123456';
        update testAccount;

        List<Account> testAccounts = [SELECT Id, OwnerId, Territory__c FROM Account LIMIT 2];
        testContacts = [SELECT Id, OwnerId FROM Contact LIMIT 3];

        System.assertEquals(1, testAccounts.size());
        System.assertEquals(2, testContacts.size());
        System.assertEquals(testTerritories.get(0).Id, testAccounts.get(0).Territory__c);
        System.assertEquals(testUser.Id, testAccounts.get(0).OwnerId);
        System.assertEquals(testUser.Id, testContacts.get(0).OwnerId);
        System.assertEquals(testUser.Id, testContacts.get(1).OwnerId);
    }

    @IsTest
    private static void assignOwnerToChildOpportunities_Test(){
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser1@testorg.com'];

        List<Territory__c> testTerritories = [SELECT Id FROM Territory__c];

        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;

        List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Integer i = 0; i < 2; i++){
            testOpportunities.add(
                new Opportunity(
                    Name = 'testName',
                    StageName = 'testStageName',
                    CloseDate = System.now().addDays(1).date(),
                    OwnerId = UserInfo.getUserId(),
                    AccountId = testAccount.Id
                )
            );
        }

        insert testOpportunities;

        testAccount.BillingPostalCode = '123456';
        update testAccount;

        List<Account> testAccounts = [SELECT Id, OwnerId, Territory__c FROM Account LIMIT 2];
        testOpportunities = [SELECT Id, OwnerId FROM Opportunity LIMIT 3];

        System.assertEquals(1, testAccounts.size());
        System.assertEquals(2, testOpportunities.size());
        System.assertEquals(testTerritories.get(0).Id, testAccounts.get(0).Territory__c);
        System.assertEquals(testUser.Id, testAccounts.get(0).OwnerId);
        System.assertEquals(testUser.Id, testOpportunities.get(0).OwnerId);
        System.assertEquals(testUser.Id, testOpportunities.get(1).OwnerId);
    }

    @IsTest
    private static void createAssignmentHistory_Test(){
        List<User> testUsers = [SELECT Id FROM User WHERE Alias IN ('1','2') ORDER BY Alias ASC];

        List<Territory__c> testTerritories = [SELECT Id FROM Territory__c ORDER BY Name ASC];

        Account testAccount = new Account(Name = 'TestAccount', BillingPostalCode = '123456');
        insert testAccount;

        testAccount = [SELECT Id, OwnerId FROM Account LIMIT 1];

        System.assertEquals(testUsers.get(0).Id, testAccount.OwnerId);

        List<Assignment_History__c> assignmentHistories = [
                SELECT Id, Previous_Owner__c, New_Owner__c, Previous_Territory__c, New_Territory__c, Account__c
                FROM Assignment_History__c
                LIMIT 2
        ];

        System.assertEquals(1, assignmentHistories.size());
        System.assertEquals(null, assignmentHistories.get(0).Previous_Owner__c);
        System.assertEquals(testUsers.get(0).Id, assignmentHistories.get(0).New_Owner__c);
        System.assertEquals(null, assignmentHistories.get(0).Previous_Territory__c);
        System.assertEquals(testTerritories.get(0).Id, assignmentHistories.get(0).New_Territory__c);
        System.assertEquals(testAccount.Id, assignmentHistories.get(0).Account__c);

        testAccount.BillingPostalCode = '654321';
        update testAccount;

        assignmentHistories = [
                SELECT Id, Previous_Owner__c, New_Owner__c, Previous_Territory__c, New_Territory__c, Account__c
                FROM Assignment_History__c
                ORDER BY CreatedDate DESC
                LIMIT 3
        ];

        Assignment_History__c assignmentHistory_1 = assignmentHistories.get(0);
        Assignment_History__c assignmentHistory_2 = assignmentHistories.get(1);

        System.assertEquals(2, assignmentHistories.size());
        System.assertEquals(assignmentHistory_1.New_Owner__c, assignmentHistory_2.Previous_Owner__c);
        System.assertEquals(testUsers.get(1).Id, assignmentHistory_2.New_Owner__c);
        System.assertEquals(assignmentHistory_1.New_Territory__c, assignmentHistory_2.Previous_Territory__c);
        System.assertEquals(testTerritories.get(1).Id, assignmentHistory_2.New_Territory__c);
        System.assertEquals(testAccount.Id, assignmentHistory_2.Account__c);
    }
}