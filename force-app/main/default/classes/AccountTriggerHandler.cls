public with sharing class AccountTriggerHandler implements ITrigger{

    public void beforeInsert(List<SObject> sObjectList) {
        assignTerritoryAndOwner_BeforeInsert((List<Account>) sObjectList);
    }

    public void beforeUpdate(List<SObject> sObjectNew, Map<Id, SObject> sObjectOldMap) {
        assignTerritoryAndOwner_BeforeUpdate((List<Account>)sObjectNew, (Map<Id, Account>)sObjectOldMap);
    }

    public void beforeDelete(Map<Id, SObject> sObjectNewMap, Map<Id, SObject> sObjectOldMap) {
    }

    public void afterInsert(List<SObject> sObjectList) {
        updateOwnerForChildRecords_AfterInsert((List<Account>)sObjectList);
        createAssignmentHistory_AfterInsert((List<Account>)sObjectList);
    }

    public void afterUpdate(List<SObject> sObjectNew, Map<Id, SObject> sObjectOldMap) {
        updateOwnerForChildRecords_AfterUpdate((List<Account>)sObjectNew, (Map<Id, Account>)sObjectOldMap);
        createAssignmentHistory_AfterUpdate((List<Account>)sObjectNew, (Map<Id, Account>)sObjectOldMap);
    }

    public void afterDelete(Map<Id, SObject> sObjectNewMap, Map<Id, SObject> sObjectOldMap) {
    }

    public void afterUndelete(Map<Id, SObject> sObjectNewMap, Map<Id, SObject> sObjectOldMap) {
    }

    private static void assignTerritoryAndOwner_BeforeInsert(List<Account> newRecords){
        assignTerritoryAndOwner_BeforeUpdate(newRecords, new Map<Id, Account>());
    }

    private static void assignTerritoryAndOwner_BeforeUpdate(List<Account> newRecords, Map<Id, Account> oldRecords){
        List<Account> accountsToProcess = new List<Account>();
        for(Account newRecord : newRecords){
            Account oldRecord = oldRecords.get(newRecord.Id);
            if((newRecord.BillingPostalCode != null && oldRecord == null)
                || (oldRecord != null && newRecord.BillingPostalCode != oldRecord.BillingPostalCode && newRecord.BillingPostalCode != null)){
                accountsToProcess.add(newRecord);
            }
        }

        if( ! accountsToProcess.isEmpty()){
            AccountService.assignTerritoryAndOwner(accountsToProcess);
        }
    }

    private static void updateOwnerForChildRecords_AfterInsert(List<Account> newRecords){
        updateOwnerForChildRecords_AfterUpdate(newRecords, new Map<Id, Account>());
    }

    private static void createAssignmentHistory_AfterInsert(List<Account> newRecords){
        createAssignmentHistory_AfterUpdate(newRecords, new Map<Id, Account>());
    }

    private static void updateOwnerForChildRecords_AfterUpdate(List<Account> newRecords, Map<Id, Account> oldRecords){
        List<Account> accountsToProcess = new List<Account>();
        for(Account newRecord : newRecords){
            Account oldRecord = oldRecords.get(newRecord.Id);
            if((newRecord.Territory__c != null && oldRecord == null)
                    ||(oldRecord != null && newRecord.Territory__c != oldRecord.Territory__c && newRecord.Territory__c != null)){
                accountsToProcess.add(newRecord);
            }
        }
        updateOwnerForChildRecords(accountsToProcess);
    }

    private static void createAssignmentHistory_AfterUpdate(List<Account> newRecords, Map<Id, Account> oldRecords){
        List<Account> accountsToProcess = new List<Account>();
        for(Account newRecord : newRecords){
            Account oldRecord = oldRecords.get(newRecord.Id);
            if((newRecord.Territory__c != null && oldRecord == null)
                    || (oldRecord != null && newRecord.Territory__c != null && newRecord.Territory__c != oldRecord.Territory__c)){
                accountsToProcess.add(newRecord);
            }
        }

        if( ! accountsToProcess.isEmpty()){
            createAssignmentHistory(accountsToProcess, oldRecords);
        }
    }

    private static void updateOwnerForChildRecords(List<Account> p_accountsToProcess){
        if( ! p_accountsToProcess.isEmpty()){
            AccountService.updateChildContactsOwnerForZipCodeTerritory(p_accountsToProcess);
            AccountService.updateChildOpportunityOwnerForZipCodeTerritory(p_accountsToProcess);
        }
    }

    private static void createAssignmentHistory(List<Account> p_new, Map<Id, Account> p_old){
        List<Assignment_History__c> assignmentHistoriesToInsert = new List<Assignment_History__c>();
        for(Account newAccount : p_new){
            Account oldAccount = new Account();
            if(p_old != null && ! p_old.isEmpty()){
                oldAccount = p_old.get(newAccount.Id);
            }

            Assignment_History__c assignmentHistory = new Assignment_History__c(
                Previous_Owner__c = oldAccount.OwnerId,
                New_Owner__c = newAccount.OwnerId,
                Previous_Territory__c = oldAccount.Territory__c,
                New_Territory__c = newAccount.Territory__c,
                Account__c = newAccount.Id,
                Changed_By__c = newAccount.LastModifiedById
            );

            assignmentHistoriesToInsert.add(assignmentHistory);
        }

        insert assignmentHistoriesToInsert;
    }
}