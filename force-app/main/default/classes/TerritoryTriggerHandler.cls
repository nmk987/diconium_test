public with sharing class TerritoryTriggerHandler implements ITrigger{
    public void beforeInsert(List<SObject> sObjectList) {
        checkNumberOfSalesRepresentatives_BeforeInsert((List<Territory__c>) sObjectList);
    }

    public void beforeUpdate(List<SObject> sObjectNew, Map<Id, SObject> sObjectOldMap) {
        checkNumberOfSalesRepresentatives_BeforeUpdate((List<Territory__c>)sObjectNew, (Map<Id, Territory__c>)sObjectOldMap);
    }

    public void beforeDelete(Map<Id, SObject> sObjectNewMap, Map<Id, SObject> sObjectOldMap) {
    }

    public void afterInsert(List<SObject> sObjectList) {
    }

    public void afterUpdate(List<SObject> sObjectNew, Map<Id, SObject> sObjectOldMap) {
        updateAccountsAndChildes_AfterUpdate((List<Territory__c>)sObjectNew, (Map<Id, Territory__c>)sObjectOldMap);
    }

    public void afterDelete(Map<Id, SObject> sObjectNewMap, Map<Id, SObject> sObjectOldMap) {
    }

    public void afterUndelete(Map<Id, SObject> sObjectNewMap, Map<Id, SObject> sObjectOldMap) {
    }

    private static void checkNumberOfSalesRepresentatives_BeforeInsert(List<Territory__c> newRecords){
        checkNumberOfSalesRepresentatives_BeforeUpdate(newRecords, new Map<Id, Territory__c>());
    }

    private static void checkNumberOfSalesRepresentatives_BeforeUpdate(List<Territory__c> newRecords, Map<Id, Territory__c> oldRecords){
        List<Territory__c> territoriesToProcess = new List<Territory__c>();
        for(Territory__c newRecord : newRecords){
            Territory__c oldRecord = oldRecords.get(newRecord.Id);
            if((oldRecord == null && newRecord.Name != null)
                    || (oldRecord != null && newRecord.Name != null && newRecord.Name != oldRecord.Name)){
                territoriesToProcess.add(newRecord);
            }
        }

        if( ! territoriesToProcess.isEmpty()){
            checkNumberOfSalesRepresentatives(territoriesToProcess);
        }
    }

    private static void updateAccountsAndChildes_AfterUpdate(List<Territory__c> newRecords, Map<Id, Territory__c> oldRecords){
        Set<Id> territoryIds = new Set<Id>();
        for(Territory__c territory : newRecords){
            if(territory.OwnerId != null && territory.OwnerId != oldRecords.get(territory.Id).OwnerId){
                territoryIds.add(territory.Id);
            }
        }

        if( ! territoryIds.isEmpty()){
            List<Account> accounts = AccountModel.selectAccountsByTerritoryIds(territoryIds);
            update AccountService.assignTerritoryAndOwner(accounts, TerritoryService.getRandomRepForTerritory(newRecords));
            AccountService.updateChildContactsOwnerForZipCodeTerritory(accounts);
            AccountService.updateChildOpportunityOwnerForZipCodeTerritory(accounts);
        }
    }

    private static void checkNumberOfSalesRepresentatives(List<Territory__c> p_territories){
        Set<String> territoriesZipCodes = new Set<String>();
        for(Territory__c territory : p_territories){
            territoriesZipCodes.add(territory.Name);
        }

        List<Territory__c> territories = TerritoryModel.selectTerritoriesByZipCodes(territoriesZipCodes);
        territories.addAll(p_territories);

        Map<String, List<Territory__c>> existingTerritoriesByZipCode = new Map<String, List<Territory__c>>();
        for(Territory__c territory : territories){
            if( ! existingTerritoriesByZipCode.containsKey(territory.Name)){
                existingTerritoriesByZipCode.put(territory.Name, new List<Territory__c>());
            }
            existingTerritoriesByZipCode.get(territory.Name).add(territory);
            if(existingTerritoriesByZipCode.get(territory.Name).size() > 3){
                territory.addError('It is not allowed to assign more then 3 sales representatives to the one zip code.');
            }
        }
    }
}