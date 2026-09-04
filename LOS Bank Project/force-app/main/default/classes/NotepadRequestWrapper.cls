public class NotepadRequestWrapper{
	public String StartDate;
	public String AccountID;
    public String CustomerID;
	public String MemoText;
	public String RequestId;
	public String OriginatingChannel;
	public String ReasonForMemo;
	public String MaintenanceMode;
	public String ReferenceNumber;
	public String Severity;
	public String TransactionBranch;
	public String MemoNumber;
	public String EndDate;
    
	public static NotepadRequestWrapper parse(String json){
		return (NotepadRequestWrapper) System.JSON.deserialize(json, NotepadRequestWrapper.class);
    }
}