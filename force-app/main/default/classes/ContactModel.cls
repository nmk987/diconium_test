public with sharing class ContactModel {
    public static List<Contact> selectContactsByAccountIds(Set<Id> p_contactIds){
        return [SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId IN :p_contactIds];
    }
}