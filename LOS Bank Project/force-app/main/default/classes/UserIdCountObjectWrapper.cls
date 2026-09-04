/* 
    @description :   This method create Wrapper
    */

global class UserIdCountObjectWrapper implements Comparable {

    public UserIdCountObject obj;
    public class UserIdCountObject{
        public Id userId{ get; set; }
        public Integer assignedRecordsCount{ get; set;}
        public Id crMgrId {get;set;}
        public Id brMgrId {get;set;}
    }
    
    // Constructor
    public UserIdCountObjectWrapper(UserIdCountObject op) {
        
        // Guard against wrapping a null 
        if(op == null) {
            Exception ex = new NullPointerException();
            ex.setMessage('UserIdCountObject argument cannot be null'); 
            throw ex;
        }
        obj = op;
    }
    
    // Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
        // Cast argument to UserIdCountObject
        UserIdCountObjectWrapper compareToCount = (UserIdCountObjectWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if ((obj.assignedRecordsCount == null) && (compareToCount.obj.assignedRecordsCount == null)) {
            // both wrappers have null Amounts
            returnValue = 0;
        } else if ((obj.assignedRecordsCount == null) && (compareToCount.obj.assignedRecordsCount != null)){
            // nulls-first implementation
            returnValue = -1;
        } else if ((obj.assignedRecordsCount != null) && (compareToCount.obj.assignedRecordsCount == null)){
            // nulls-first implementation
            returnValue = 1;
        } else if (obj.assignedRecordsCount > compareToCount.obj.assignedRecordsCount) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (obj.assignedRecordsCount < compareToCount.obj.assignedRecordsCount) {
            // Set return value to a negative value.
            returnValue = -1;
        } 
        return returnValue;
    }
}