public class IBBErrorResponseWrapper {

    public class Errors {
        public Error Error;
    }
    
    public String ServiceExecutionStatus;
    public Errors Errors;
    
    public class Error {
        public String Code;
        public String Message;
    }
}