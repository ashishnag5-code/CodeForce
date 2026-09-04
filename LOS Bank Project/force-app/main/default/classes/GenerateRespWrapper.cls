public class GenerateRespWrapper{
    public response_data response_data;
    public response_status response_status;
    public class response_data {
        public String data;	//PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPE90cFJlcyB0eG49Im51bGwiIGNvZGU9IjYyNTcyMzY3ZDgzYTRmOWE5NjFkMGMxMGRjYmJjNTIyIiB0cz0iMjAyMS0xMS0wMlQxNzozMzo1NS44ODErMDU6MzAiIHJldD0ieSIgaW5mbz0iMDF7QSwyMDIxLTExLTAyVDE3OjM0OjMyLDIuNSxlZTI5NDMwMjMxNGIzZDRmZDBlMDdkYzJjNDMwNDk1NDgxNGI5NDlhNzExNjk5YjVhYjQ5Mjg5NTRmYWJmZDRjLGE1ZDllZmJjODFkOGNmNDNlNmY2ZDRjZjZhZDg2YjQ0YWRlNzAzNDlhYTA0NjJkZmJkZDIyMjFkNDUyNmM1MWIsYTVkOWVmYmM4MWQ4Y2Y0M2U2ZjZkNGNmNmFkODZiNDRhZGU3MDM0OWFhMDQ2MmRmYmRkMjIyMWQ0NTI2YzUxYiwqKioqKioqOTUwNSxOQX0iLz4=
        public String format;	//XML
    }
    public class response_status {
        public String code;	//000
        public String message;	//OTP sent successfully
        public String status;	//SUCCESS
    }
    public static GenerateRespWrapper parse(String json){
        return (GenerateRespWrapper) System.JSON.deserialize(json, GenerateRespWrapper.class);
    }
}