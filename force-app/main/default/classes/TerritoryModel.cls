public with sharing class TerritoryModel {
    public static List<Territory__c> selectTerritoriesByZipCodes(Set<String> p_territoriesZipCodes){
        return [SELECT Id, Name, OwnerId FROM Territory__c WHERE Name IN :p_territoriesZipCodes];
    }
}