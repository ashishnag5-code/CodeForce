/**
* @description       : 
* @author            : Harshit Goyal | Salesforce
* @group             : 
* @last modified on  : 12-19-2022
* @last modified by  : Harshit Goyal | Salesforce
* Added Constructors : Yash SHukla
**/
public class AadharTokenReqWrapper {
    
    public Headers headers;
    public Request request;
    public String RequestId;
    public String OriginatingChannel;
    
    public class Headers {
        //public String channel;
        //public String requestId;
        public String client_code;
        public String sub_client_code;
        public String channel_code;
        public String channel_version;
        public String stan;
        public String client_ip;
        public String transmission_datetime;
        public String operation_mode;
        public String run_mode;
        public String actor_type;
        public String user_handle_type;
        public String user_handle_value;
        public String location;
        public String function_code;
        public String function_sub_code;
        public Headers(){
            client_code = '';
            sub_client_code = '';
            channel_code = '';
            channel_version = '';
            stan = '';
            client_ip = '';
            transmission_datetime = '';
            operation_mode = '';
            run_mode = '';
            actor_type = '';
            user_handle_type = '';
            user_handle_value = '';
            location = '';
            function_code = '';
            function_sub_code = '';
        }
    }
    
    public class Request {
        public String client_ref_number;
        public String ekyc_flag;
        public String hmac;
        public String tokenize_data;
        public String purpose;
        public Skey skey;
        public Request(){
            client_ref_number = '';
            ekyc_flag = '';
            hmac = '';
            tokenize_data = '';
            purpose = '';
            skey = new Skey();
        }
    }
    
    public class Skey {
        public String ci;
        public String value;
        public Skey(){
            ci = '';
            value = '';
        }
    }

}