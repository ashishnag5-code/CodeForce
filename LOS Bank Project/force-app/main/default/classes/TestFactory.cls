public class TestFactory {

    /*
    @description :  Creates a single sObject with default values (if specified in TestFactoryDefaults)
    @param :  SObject   sObj    Type of sObject to create.
    @return : SObject
    */
    public static SObject createSObject(SObject sObj) { 

        String objectName = String.valueOf(sObj.getSObjectType());
        String defaultClassName =objectName.replaceAll('__(c|C)$|__', '') + 'Defaults';//Eg. Account-->AccountDefaults,Test__c-->TestDefaults
        if (Type.forName('TestFactoryDefaults.'+ defaultClassName) != null) {
            sObj = createSObject(sObj,'TestFactoryDefaults.' +defaultClassName);
        }
        return sObj;
    }

    /*
    @description : Creates a single sObject with default values (if specified in TestFactoryDefaults)
    @param :  SObject  sObj      Type of sObject to create.
    @param :  Boolean  doInsert  should this object be inserted?
    @return :  SObject
    */
    public static SObject createSObject(SObject sObj, Boolean doInsert) {
        SObject retObject = createSObject(sObj);
        if (doInsert) {
            insert retObject;
        }
        return retObject;
    }
    /*
    @description :   Creates a single sObject with default values specified in class name passed as param.
    @param :  SObject  sObj    Type of sObject to create
    @param :  String   defaultClassName    Name of the class to provide field defaults
    @exception :   TestFactoryException when defaultClassName param is not a valid type.
    @return :  SObject
    */
    public static SObject createSObject(SObject sObj, String defaultClassName) {
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            throw new TestFactoryException('Invalid defaults class.');
        }
        FieldDefaults defaults = (FieldDefaults) t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults());
        return sObj;
    }

    /*
    @description :   Creates a single sObject with default values specified in class name passed as param.
    @param :  SObject  sObj    Type of sObject to create
    @param :  String   defaultClassName    Name of the class to provide field defaults
    @param :  Boolean  doInsert    Boolean should this method insert the created object?
    @return : SObject
    */
    public static SObject createSObject(SObject sObj,String defaultClassName,Boolean doInsert) {
        SObject retObject = createSObject(sObj, defaultClassName);
        if (doInsert) {
            insert retObject;
        }
        return retObject;
    }

    /*
    @description :   Creates a list of sObjects with default values (if specified in TestFactoryDefaults)
    @param :   SObject     sObj            Type of sObjects to create
    @param :   Integer     numberOfObjects Integer number of objects to create
    @return :  SObject[]
    */
    public static SObject[] createSObjectList(SObject sObj,Integer numberOfObjects) {
        return createSObjectList(sObj, numberOfObjects, (String) null);
    }
    /*
    @description :   Creates a list of sObjects with default values (if specified in TestFactoryDefaults)
    @param :  SObject     sObj            Type of sObjects to create
    @param :  Integer     numberOfObjects Integer number of objects to create
    @param    Boolean     doInsert        should this method insert the created object?
    @return : SObject[]
    */
    public static SObject[] createSObjectList(SObject sObj,Integer numberOfObjects,Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj,numberOfObjects,(String) null);
        if (doInsert) {
            insert retList;
        }
        return retList;
    }

    /*
    @description :   Creates a list of sObjects with default values specified in class name passed as param
    @param :  SObject     sObj             Type of sObjects to create
    @param :  Integer     numberOfObjects  Integer number of objects to create
    @param :  String      defaultClassName String name of a class providing defaults
    @param    Boolean     doInsert         should this method insert the created object?
    @return : SObject[]
    */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static SObject[] createSObjectList(SObject sObj,Integer numberOfObjects,String defaultClassName,Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj,numberOfObjects,defaultClassName);
        if (doInsert) {
            insert retList;
        }
        return retList;
    }
    /*
    @description :   Creates a list of sObjects with default values specified in class name passed as param
    @param :  SObject     sObj             Type of sObjects to create
    @param :  Integer     numberOfObjects  Integer number of objects to create
    @param :  String      defaultClassName String name of a class providing defaults
    @return : SObject[]
    */
    public static SObject[] createSObjectList(SObject sObj,Integer numberOfObjects,String defaultClassName) {
        SObject[] sObjs = new List<SObject>{};
        SObject newObj;

        if (defaultClassName == null) {
            newObj = createSObject(sObj);
        } else {
            newObj = createSObject(sObj, defaultClassName);
        }


        String nameField = String.valueOf(nameFieldMap.get(sObj.getSObjectType()));

        if (nameField == null) {
            nameField = 'Name';
        }

        Boolean nameIsAutoNumber = sObj.getSObjectType()
                .getDescribe()
                .fields.getMap()
                .get(nameField)
                .getDescribe()
                .isAutoNumber();

        // Clone the object the number of times requested. Increment the name field so each record is unique
        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = newObj.clone(false, true);
            if(nameField == 'Username'){
                clonedSObj.put(nameField,(String) String.valueOf(i)+clonedSObj.get(nameField));
            }
            else if (!nameIsAutoNumber) {
                clonedSObj.put(nameField,(String) clonedSObj.get(nameField) +' ' +i);
            }
            sObjs.add(clonedSObj);
        }
        return sObjs;
    }

    /*
     @description :   Sets field defaults on the sObj given the map of defaults.
     @param :  SObject                  sObj        Obj to manipulate.
     @param :  Map<Schema.SObjectField  defaults    Defaults map of sObjectField to Object to use for values.
     @return :  void
    */
    private static void addFieldDefaults(SObject sObj,Map<Schema.SObjectField, Object> defaults) {
        // Loop through the map of fields and if they weren't specifically assigned, fill them.
        Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
        for (Schema.SObjectField field : defaults.keySet()) {
            if (!populatedFields.containsKey(String.valueOf(field))) {
                sObj.put(field, defaults.get(field));
            }
        }
    }


    /*
    @Interface Name : FieldDefaults
    @Description :  Use the FieldDefaults interface to set up values you want to default in for all objects
    */
    public interface FieldDefaults {

        /*
            @description  Interface used by implementing classes to define defaults.
            @return       Map<Schema.SObjectField, Object>
         */
        Map<Schema.SObjectField, Object> getFieldDefaults();

    }
    private static Map<Schema.SObjectType, Schema.SObjectField> nameFieldMap = new Map<Schema.SObjectType, Schema.SObjectField>{
            Contact.SObjectType => Contact.LastName,
            Case.SObjectType => Case.CaseNumber,
            Applicant__c.SObjectType =>Applicant__c.Name,
            User.SObjectType => User.Username
    };

    /**
     * @description Internal custom exception class
     */
    public class TestFactoryException extends Exception {
    }

}