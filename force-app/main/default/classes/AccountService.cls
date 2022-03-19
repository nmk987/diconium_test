public with sharing class AccountService {
    public static List<Account> assignTerritoryAndOwner(List<Account> p_accounts){
        Map<String, Territory__c> territoriesByZipCode = TerritoryService.getRandomTerritoryByZipCode(p_accounts);
        return assignTerritoryAndOwner(p_accounts, territoriesByZipCode);
    }

    public static List<Account> assignTerritoryAndOwner(List<Account> p_accounts, Map<String, Territory__c> p_territoriesByZipCode){
        List<Account> accountsToUpdate = new List<Account>();
        for(Account account : p_accounts){
            if(p_territoriesByZipCode.containsKey(account.BillingPostalCode)){
                account.Territory__c = p_territoriesByZipCode.get(account.BillingPostalCode).Id;
                account.OwnerId = p_territoriesByZipCode.get(account.BillingPostalCode).OwnerId;
                accountsToUpdate.add(account);
            }
        }
        return accountsToUpdate;
    }

    public static void updateChildContactsOwnerForZipCodeTerritory(List<Account> p_accounts){
        Map<Id, Account> accountsByIds = new Map<Id, Account>(p_accounts);
        List<Contact> contacts = [SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId IN :accountsByIds.keySet()];

        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        for(Contact contact : contacts){
            if( ! contactsByAccountId.containsKey(contact.AccountId)){
                contactsByAccountId.put(contact.AccountId, new List<Contact>());
            }
            contactsByAccountId.get(contact.AccountId).add(contact);
        }

        List<Contact> contactsToUpdate = new List<Contact>();
        for(Account account : p_accounts){
            if(contactsByAccountId.containsKey(account.Id)){
                for(Contact contact : contactsByAccountId.get(account.Id)){
                    contact.OwnerId = account.OwnerId;
                    contactsToUpdate.add(contact);
                }
            }
        }

        update contactsToUpdate;
    }

    public static void updateChildOpportunityOwnerForZipCodeTerritory(List<Account> p_accounts){
        Map<Id, Account> accountsByIds = new Map<Id, Account>(p_accounts);
        List<Opportunity> opportunities = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE AccountId IN :accountsByIds.keySet()];

        Map<Id, List<Opportunity>> opportunitiesByAccountId = new Map<Id, List<Opportunity>>();
        for(Opportunity opportunity : opportunities){
            if( ! opportunitiesByAccountId.containsKey(opportunity.AccountId)){
                opportunitiesByAccountId.put(opportunity.AccountId, new List<Opportunity>());
            }
            opportunitiesByAccountId.get(opportunity.AccountId).add(opportunity);
        }

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for(Account account : p_accounts){
            if(opportunitiesByAccountId.containsKey(account.Id)){
                for(Opportunity opportunity : opportunitiesByAccountId.get(account.Id)){
                    opportunity.OwnerId = account.OwnerId;
                    opportunitiesToUpdate.add(opportunity);
                }
            }
        }

        update opportunitiesToUpdate;
    }
}