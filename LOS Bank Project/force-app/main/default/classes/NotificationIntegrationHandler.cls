public with sharing class NotificationIntegrationHandler {
   
    public static List<String> generateSMSRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        SMSDetailsRequestWrapper smsRequestWrapper = new SMSDetailsRequestWrapper();
        String Message = JSON.serialize(paramsMap.get('Message'));
       // smsRequestWrapper.Message = Message;
        smsRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        smsRequestWrapper.Channel = String.valueOf(paramsMap.get('Channel'));
        smsRequestWrapper.GroupID =String.valueOf(paramsMap.get('GroupID'));
        smsRequestWrapper.ContentType = String.valueOf(paramsMap.get('ContentType'));
        smsRequestWrapper.NationalorInternational = String.valueOf(paramsMap.get('NationalorInternational'));
        smsRequestWrapper.MessageType = String.valueOf(paramsMap.get('MessageType'));
        smsRequestWrapper.IsOTPMessage = String.valueOf(paramsMap.get('IsOTPMessage'));
        smsRequestWrapper.LanguageId = String.valueOf(paramsMap.get('LanguageId'));
        lstString.add(JSON.serialize(smsRequestWrapper));   
        return lstString;
    }

    public static List<String> generateEmailRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        EmailDetailsRequestWrapper emailRequestWrapper = new EmailDetailsRequestWrapper();
        
        emailRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        emailRequestWrapper.Channel = String.valueOf(paramsMap.get('Channel'));
        emailRequestWrapper.TO =String.valueOf(paramsMap.get('TO'));
        emailRequestWrapper.CC = String.valueOf(paramsMap.get('CC'));
        emailRequestWrapper.BCC = String.valueOf(paramsMap.get('BCC'));
        emailRequestWrapper.Subject = String.valueOf(paramsMap.get('Subject'));
        emailRequestWrapper.Text = String.valueOf(paramsMap.get('Text'));
        emailRequestWrapper.Priority = String.valueOf(paramsMap.get('Priority'));
        emailRequestWrapper.Attachment = String.valueOf(paramsMap.get('Attachment'));
        

        lstString.add(JSON.serialize(emailRequestWrapper));   
        return lstString;
    }

    public static List<String> generateWhatsappRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        WhatsAppDetailsRequestWrapper whatsappRequestWrapper = new WhatsAppDetailsRequestWrapper();
        
        whatsappRequestWrapper.requestId = IntegrationUtility.getReferenceId();
        String client = String.valueOf(paramsMap.get('client_data'));
        whatsappRequestWrapper.client_data = client;

        whatsappRequestWrapper.authorization =String.valueOf(paramsMap.get('authorization'));
        whatsappRequestWrapper.whatsapp_bsp = String.valueOf(paramsMap.get('whatsapp_bsp'));
        whatsappRequestWrapper.channel = String.valueOf(paramsMap.get('channel'));
        whatsappRequestWrapper.campaign_id = String.valueOf(paramsMap.get('campaign_id'));
        
        

        lstString.add(JSON.serialize(whatsappRequestWrapper));   
        return lstString;
    }


    public static List<String> generateShortenURLServiceRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;

        KarixDetailsRequestWrapper karixWrapper = new KarixDetailsRequestWrapper();
        karixWrapper.LongURL = String.valueOf(paramsMap.get('LongURL'));
        karixWrapper.MobileNumber = String.valueOf(paramsMap.get('MobileNumber'));
        karixWrapper.RequestId = String.valueOf(paramsMap.get('RequestId'));
        karixWrapper.Channel = String.valueOf(paramsMap.get('Channel'));
        lstString.add(JSON.serialize(karixWrapper));   
        return lstString;
    }





     




    public class SMSDetailsRequestWrapper{
       
       // public String Message;
        public String RequestId;
        public String Channel;
        public String GroupID;
        public String ContentType;
        public String NationalorInternational;
        public String MessageType;
        public String IsOTPMessage;
        public String LanguageId;
    }

    public class EmailDetailsRequestWrapper{
       
   
        public String RequestId;
        public String Channel;
        public String TO;
        public String CC;
        public String BCC;
        public String Subject;
        public String Text;
        public String Priority;
        public String Attachment;
    }

    public class WhatsappDetailsRequestWrapper{
        public String authorization;
        public String client_data;
        public String requestId;
        public String whatsapp_bsp;
        public String channel;
        public String campaign_id;

    }
    public class KarixDetailsRequestWrapper{
        public String LongURL;
        public String MobileNumber;
        public String RequestId;
        public String Channel;
    }

    public class KarixResponseWrapper{
        public String statusCode;
        public String statusDesc;
        public String shortUrl;
        public String requestId;
        public String shortCode;
       
    }

   
    public class emailResponseWrapper{
        public String ResponseCode;
        public String ResponseMessage;
        public String ExtendedErrorDetails;
    }
     


}