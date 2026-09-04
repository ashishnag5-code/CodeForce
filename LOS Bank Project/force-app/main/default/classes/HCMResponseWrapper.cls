public class HCMResponseWrapper {
    
    public EmployeeDetails EmployeeDetails;

    public class PersonalAddress {
        public String AddressLine3;
        public String AddressLine2;
        public String AddressLine1;
        public String State;
        public String Country;
        public String PostalCode;
        public String City;
    }

    public class EmployeeDetails {
        public String DepartmentCode;
        public String Designation;
        public String EmployeeCode;
        public String ProductCode;
        public String CurrentStatus;
        public Object Photo;
        public String VerticalProduct;
        public Object MonthlyRemuneration;
        public String MobileNumber;
        public String BusinessUnit;
        public String JobCode;
        public PersonalAddress PersonalAddress;
        public String DepartmentName;
        public String BranchName;
        public String PAN;
        public String EmployeeName;
        public String BranchCode;
        public String Employment_Start_Date;
        public Object Date_Of_Leaving_Service;
        public String BusinessUnitCode;
    }

    
    public static HCMResponseWrapper parse(String json) {
        HCMResponseWrapper objHCMResp;
        try{
            objHCMResp = new HCMResponseWrapper();
            objHCMResp = (HCMResponseWrapper) System.JSON.deserialize(json, HCMResponseWrapper.class);
            //return (HCMResponseWrapper) System.JSON.deserialize(json, HCMResponseWrapper.class);
        }
        catch(Exception e){
            objHCMResp = new HCMResponseWrapper();
        }
        return objHCMResp;
    }
}