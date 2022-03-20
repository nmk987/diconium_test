public with sharing class AccountModel {
    public static List<Account> selectAccountsByTerritoryIds(Set<Id> p_territoryIds){
        return [SELECT Id, OwnerId, BillingPostalCode, Territory__c FROM Account WHERE Territory__c IN :p_territoryIds];
    }
}