public with sharing class OpportunityModel {
    public static List<Opportunity> selectOpportunitiesByAccountIds(Set<Id> p_accountsIds){
        return [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE AccountId IN :p_accountsIds];
    }
}