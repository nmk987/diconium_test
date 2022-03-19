public interface ITrigger {
    void beforeInsert(List<sObject> sObjectList);
    void beforeUpdate(List<sObject> sObjectNew, Map<Id, sObject> sObjectOldMap);
    void beforeDelete(Map<Id, sObject> sObjectNewMap, Map<Id, sObject> sObjectOldMap);
    void afterInsert(List<sObject> sObjectList);
    void afterUpdate(List<sObject> sObjectNew, Map<Id, sObject> sObjectOldMap);
    void afterDelete(Map<Id, sObject> sObjectNewMap, Map<Id, sObject> sObjectOldMap);
    void afterUndelete(Map<Id, sObject> sObjectNewMap, Map<Id, sObject> sObjectOldMap);
}