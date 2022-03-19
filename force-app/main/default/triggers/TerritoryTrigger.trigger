trigger TerritoryTrigger on Territory__c(
  after delete,
  after insert,
  after update,
  before delete,
  before insert,
  before update,
  after undelete
) {
  TriggerFactory.createHandler('TerritoryTriggerHandler');
}