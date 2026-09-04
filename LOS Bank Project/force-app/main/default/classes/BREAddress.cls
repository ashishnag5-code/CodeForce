public class BREAddress {
    public String addressType;	//PERMANENT
    public String pinCode;	//400029
    public String district;	//Mumbai
    public String city;	//Mumbai
    public String state;	//MH
    public String country;	//IN
    public Double timeAtCurrentAddress = 0.0;	//4
    public String ownershipStatus;	//PARENTAL
    public String propertyType;	//BUNGALOW
    public Double distanceFromBranch = 0.00;	//5
    public boolean isNegativeArea = false;
    public boolean isResiCumOffice = false;
    public String pinCodeCategory;	//WORKING
    public String taluka {get;set;}
    public String locationType = 'URBAN';
    public String locationSubType = 'METRO';
    // Optional - Differences Missed
    //public String locationSubType = 'NON_METRO';
    //public String locationType = 'URBAN';
    //public Double timeAtCurrentCity = 0;
}