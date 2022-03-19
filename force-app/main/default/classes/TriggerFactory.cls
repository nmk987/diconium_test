public with sharing class TriggerFactory {
    public static void createHandler(String sObjectHandler) {
        ITrigger handler = getHandler(sObjectHandler);
        execute(handler);
    }

    private static ITrigger getHandler(String sObjectHandler) {
        try {
            Type customType = Type.forName(sObjectHandler);
            return (ITrigger) customType.newInstance();
        } catch (Exception expObj) {
            throw new TriggerException('No Trigger Handler registered: ' + sObjectHandler);
        }
    }

    private static void execute(ITrigger handler) {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert(Trigger.New);
            }
            if (Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.New, Trigger.oldMap);
            }
            if (Trigger.isDelete) {
                handler.beforeDelete(Trigger.newMap, Trigger.oldMap);
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                handler.afterInsert(Trigger.New);
            }
            if (Trigger.isUpdate) {
                handler.afterUpdate(Trigger.New, Trigger.oldMap);
            }
            if (Trigger.isDelete) {
                handler.afterDelete(Trigger.newMap, Trigger.oldMap);
            }
            if (Trigger.isUndelete) {
                handler.afterUndelete(Trigger.newMap, Trigger.oldMap);
            }
        }
    }

    class TriggerException extends Exception { }
}