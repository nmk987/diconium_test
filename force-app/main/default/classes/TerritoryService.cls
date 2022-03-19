public with sharing class TerritoryService {
    public static Map<String, Territory__c> getRandomTerritoryByZipCode(List<Account> p_accounts){
        Map<String, List<Account>> accountsByZipCodes = new Map<String, List<Account>>();
        for(Account account : p_accounts){
            String key = account.BillingPostalCode;
            if( ! accountsByZipCodes.containsKey(key)){
                accountsByZipCodes.put(key, new List<Account>());
            }
            accountsByZipCodes.get(key).add(account);
        }
        List<Territory__c> territories = TerritoryModel.selectTerritoriesByZipCodes(accountsByZipCodes.keySet());
        return TerritoryService.getRandomRepForTerritory(territories);
    }

    public static Map<String, Territory__c> getRandomRepForTerritory(List<Territory__c> p_territories){
        List<Territory__c> randomList = new List<Territory__c>();

        List<Territory__c> cloneTerritories = p_territories.clone();
        for(Integer i = 0; i < p_territories.size(); i++){
            Integer index = getRandomInRange(0, cloneTerritories.size() - 1);
            randomList.add(cloneTerritories.get(index));
            cloneTerritories.remove(index);
        }

        Map<String, Territory__c> territoriesByZipCode = new Map<String, Territory__c>();
        for(Territory__c territory : randomList){
            territoriesByZipCode.put(territory.Name, territory);
        }

        return territoriesByZipCode;
    }

    public static Integer getRandomInRange(Integer p_from, Integer p_to){
        return Integer.valueOf(Math.random() * ((p_to-p_from)+1) + p_from);
    }
}