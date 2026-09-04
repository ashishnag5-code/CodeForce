public class WelcomeLetterPDFUtil implements Comparable {
    public enum SortOrder {ASCENDING,DESCENDING}
    
    
    WelcomeLetterPDFController.EMIScheduleWrapper record;
    SortOrder sortOrderValue;
    
    public WelcomeLetterPDFUtil(WelcomeLetterPDFController.EMIScheduleWrapper record, SortOrder sortOrderValue){
        this.record = record;
        this.sortOrderValue =sortOrderValue;
    }
    
    public Integer compareTo(Object newObj){
        WelcomeLetterPDFController.EMIScheduleWrapper newRec = ((WelcomeLetterPDFUtil) newObj).record;
        return compareInteger((Integer) record.InstallmentCounter,(Integer) newRec.InstallmentCounter);
    }
    public Integer compareInteger(Integer val1,Integer val2){
        if(sortOrderValue.equals(SortOrder.ASCENDING)){
            return val1 < val2 ? -1 : val1 == val2 ? 0 : 1;
        }
        else{
            return val1 < val2 ? 1 : val1 == val2 ? 0 : -1;
        }
    }
    
    
    
    public static void sortRecords(List<WelcomeLetterPDFController.EMIScheduleWrapper> records, SortOrder sortOrderValue){
        List<WelcomeLetterPDFUtil> sortUtilList = new List<WelcomeLetterPDFUtil>();
        for(WelcomeLetterPDFController.EMIScheduleWrapper record : records){
            sortUtilList.add(new WelcomeLetterPDFUtil(record, sortOrderValue));
        }
        sortUtilList.sort();
        records.clear();
        for(WelcomeLetterPDFUtil sortUtil : sortUtilList){
            sortUtil.record.InstallmentStartDate = dateConversion(sortUtil.record.InstallmentStartDate);
            sortUtil.record.InstallmentDate = dateConversion(sortUtil.record.InstallmentDate);
            records.add(sortUtil.record);
        }
    }
    
    public static String dateConversion(String inputDate){
        String formatedDate;
        if(inputDate.length()==8){
            List<String> datevalue = inputDate.split('');
            formatedDate = datevalue[0]+datevalue[1]+datevalue[2]+datevalue[3]+'-'+datevalue[4]+datevalue[5]+'-'+datevalue[6]+datevalue[7];
        }
        else{
            formatedDate = inputDate;
        }
        return formatedDate;
    }
    
}