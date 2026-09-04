public class LogMaskingUtility {
    public static String returnMaskedData(String request, String response, String masterName) {
        Boolean isRequest = request != null;
        switch on String.valueOf(masterName) {
        	when 'Aadhaar - Biometric' {
            	if (isRequest){
                    string req = request;
					String substr = '{"uid":"';
					Integer startIndex = req.indexOf(substr);
                    if(startIndex!=-1){
						Integer endIndex = startIndex + substr.length();
						string replacementString = '********';
						String modifiedString = req.replace(req.substring(endIndex, endIndex+8), replacementString);
                    	substr = '{"user_handle_value":"';
                    	startIndex = modifiedString.indexOf(substr);
                    	endIndex = startIndex + substr.length();
						return modifiedString.replace(modifiedString.substring(endIndex, endIndex+8), replacementString);
                    }
                    else{
                        return req;
                    }
                 }
                else{
                    return response;
                }
           }
           when 'Aadhar Token Service' {
            	if (isRequest){
                    string req = request;
					String substr = '{"tokenize_data":"';
					Integer startIndex = req.indexOf(substr);
                    if(startIndex!=-1){
						Integer endIndex = startIndex + substr.length();
						string replacementString = '********';
						String modifiedString = req.replace(req.substring(endIndex, endIndex+8), replacementString);
						return modifiedString;
                    }
                    else{
                        return req;
                    }
                 }
               else{
                    string req = response;
					String substr = '{"uid_token":"';
					Integer startIndex = req.indexOf(substr);
                    if(startIndex!=-1){
						Integer endIndex = startIndex + substr.length();
						string replacementString = '********';
						String modifiedString = req.replace(req.substring(endIndex, endIndex+8), replacementString);
						return modifiedString;
                    }
                   else{
                        return req;
                    }
               }        
           }
           when 'Adhar - Generate OTP' {
            	if (isRequest){
                    string req = request;
					String substr = '{"uid":"';
					Integer startIndex = req.indexOf(substr);
                    if(startIndex!=-1){
						Integer endIndex = startIndex + substr.length();
						string replacementString = '********';
						String modifiedString = req.replace(req.substring(endIndex, endIndex+8), replacementString);
                    	substr = '{"user_handle_value":"';
                    	startIndex = modifiedString.indexOf(substr);
                    	endIndex = startIndex + substr.length();
						return modifiedString.replace(modifiedString.substring(endIndex, endIndex+8), replacementString);
                    }
                    else{
                        return request;
                    }
                 }
               else{
                   return response;
               }
           }
           when 'Adhar - Validate OTP' {
            	if (isRequest){
                    string req = request;
					String substr = '{"uid":"';
					Integer startIndex = req.indexOf(substr);
                    if(startIndex!=-1){
						Integer endIndex = startIndex + substr.length();
						string replacementString = '********';
						String modifiedString = req.replace(req.substring(endIndex, endIndex+8), replacementString);
                    	substr = '{"user_handle_value":"';
                    	startIndex = modifiedString.indexOf(substr);
                    	endIndex = startIndex + substr.length();
						return modifiedString.replace(modifiedString.substring(endIndex, endIndex+8), replacementString);
                    }
                    else{
                        return request;
                    }
                }
               else{
                   return response;
               }
                    
           }
           when 'Adhar OCR' {
            	if (isRequest){
                    return request;
                 }
                else{
                     string req = response;
                    String substr = '"ocrData":{"aadhaar":{"value":"';
					Integer startIndex = req.indexOf(substr);
                    if(startIndex!=-1){
						Integer endIndex = startIndex + substr.length();
						string pan = req.substring(endIndex,endIndex+12);
						string replace = '********'+pan.substring(8,12);
						req = req.replace(pan,replace);
                    }
                    return req;
                }   
           }
            /*
           when else {
                if (isRequest){
                    return request;
                 }
               else{
                   return response;
               }
   		  }*/
       }
       if (isRequest){
       	return request;
       }
       return response;
    }
}