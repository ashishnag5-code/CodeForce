/**
 * Created by ngundurao on 11/10/22.
 */

public with sharing class MobileOTPRequestWrapper {
    public String requestId{get; set;}
    public String channel {get; set;}
    public String mobile {get; set;}
    public String otptype {get; set;}
    public String otplength {get; set;}
    public String otptimeout {get; set;}
    public String msgContent {get; set;}
    public String custRef {get; set;}
}