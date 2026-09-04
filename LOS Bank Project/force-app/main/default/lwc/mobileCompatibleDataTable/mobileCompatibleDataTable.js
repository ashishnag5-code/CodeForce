import { LightningElement,api,track,wire } from 'lwc';
import getCustomMetadataColumnss from '@salesforce/apex/MobileCompatibleDataTableController.getCustomMetadataColumns';
import { NavigationMixin } from 'lightning/navigation';
const DELAY = 500;  
export default class MoblieCompatibleDataTable extends NavigationMixin(LightningElement) {

    @api records;                   //stores the data coming from parent component
    @api configurableMetaDataTable  //Custom Metadata Api Name coming from parent component
    @api rowactions;                //row actions like view, edit coming from parent component
    @api screenWidth                //ScreenWidth like SMALL,MEDIUM, LARge coming from parent component                 
    @api title                      //Title for the component, will get while placing in app builder
    originalRecords                 //Original copy the data
    showCustomButton                //CustomBox to show when records are checked
    hideCheckboxColumn              //Checkbox of  the tile
    checkedCount=0                  //To calculate the count of the checked tiles
    FilterByOptions                 //Filter ComboBox options
    filterBy='All'                  //Filter ComboBox value, Default value is ALL
    searchKey                       //Search key entered in filter input box
    timer                           //variable used to achieve debouncing
    showFilters = true              //To show filters 
    @track filteredData=[]          //To store the filtered Data
                    
    @track columns;                 //Build the columns              
    headerField;                    //Header field from our custom metadata      
    error                           //Error message if there is any error while loading the data
    recordIcon;                     //RecordIcon specified in custom metadata like standard:opportunity               
    sortedBy;                       //
    sortByField;                    //sortable comboBox value
    selectedRecords = [];           //To get selected records when each tile is selected and send those ID's to parent component
    smallDeviceSize = 6             
    mediumDeviceSize = 6
    largeDeviceSize = 4
    //Screens for filter and sorting
    
    filterMediumAndLargeDeviceSize =2
    filterInpMedAndLargeDeviceSize = 7
    sortMedAndLargeDeviceSize = 3

    @track resultData = [];         //to Structure of the data to show in UI
    @track isLoaded = false;        //Spinner
    @track sortDirection = 'asc';   //Sort Direction like Asc,Desc
    @track sortOptions = [];        //SortBy ComboBox options     
    @track isSortable = false;      //to check sortable is enabled in columns custom metadata 
    @track columnsData = []         //Generate columns like label, fieldName, sortable from columns we provided in Custom Metadata

   connectedCallback(){
   // console.log(`screen width from parent ${this.screenWidth}`)
    this.setScreenSizes();
    getCustomMetadataColumnss({metadataName : this.configurableMetaDataTable}).then(result =>{
        console.log('result');
        console.log(result);
        console.log(`header Field --> ${result[0].HeaderField__c}`)
        console.log(`Record Icon  --> ${result[0].Icon__c}`)
        console.log(`CheckboxColumn__c Field --> ${result[0].CheckboxColumn__c}`)
        this.headerField = result[0].HeaderField__c;
        this.recordIcon  = result[0].Icon__c;
        this.hideCheckboxColumn = result[0].CheckboxColumn__c;
        //this.showFilters = result[0].Filters__c;
        this.generateColumnsArray(result[0].Fields_Data_Tables__r);
        this.sortByPicklistValue();
        if(this.records){
            this.wrapperColumnsAndRecords(this.records);
        }
        this.originalRecords = this.records
    }).catch(error=>{
        //console.error(error.body.message)
        this.error = error.body.message
        this.resultData = undefined;
    })
  }

  setScreenSizes(){
      if(this.screenWidth === 'SMALL'){
          this.smallDeviceSize = 12
          this.largeDeviceSize = 4
          this.mediumDeviceSize = 6
          this.filterMediumAndLargeDeviceSize = 12
          this.filterInpMedAndLargeDeviceSize = 4
          this.sortMedAndLargeDeviceSize = 6
      }
      
  }

       generateColumnsArray(colArray){
        debugger;
            colArray.forEach(element=>{
                    const col = {}
                    col.label     = element.Field_Label__c
                    col.fieldName = element.FieldApi_Name__c
                    col.sortable  = element.Sortable__c
                    this.columnsData.push(col)
                    
            })

            //FilterBy options
            this.FilterByOptions = colArray.map(field=>{
                return {label: field.Field_Label__c, value: field.FieldApi_Name__c}
            })
            this.FilterByOptions.unshift({label: 'All', value: 'All'})
            this.columns = this.columnsData
       }

       wrapperColumnsAndRecords(records){ 
        debugger;
           this.isLoaded=true;
           this.resultData=[];
           this.filteredData=[];    
           for(var rec in records){
               var tableRows = [];
               var finalRow = [];
               var rowval = records[rec]; 
               let header = {};
               let detail = {};
               var recordDetail = rowval;

               header = { 
                   "id" : '/'+rowval.Id ,
                   "name" : rowval[this.headerField],
   
               };    
               this.columns.map(col=>{

                tableRows.push(
                     {
                         name:  col.label,
                         [col.fieldName] : rowval[col.fieldName] ? rowval[col.fieldName]  : ' ',
                         fieldAndItsValue: {[col.fieldName] : rowval[col.fieldName] ? rowval[col.fieldName]  : ' '} ,             
                         label : col.label,
                         value: rowval[col.fieldName] ? rowval[col.fieldName]  : ' ',
                         Id : rowval.Id
                     })
                })
    
               detail = { tableRows }
               finalRow = { header, detail, recordDetail };      
               this.resultData.push(finalRow); 
               this.filteredData.push(finalRow);
              
           }
           this.isLoaded=false;
           
       }
       //Select action like view and edit 
       selectAction(event) {
           const actionName = event.detail.value;
           const rowId = event.target.dataset.record; 
           switch (actionName){
                case 'view':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: rowId,
                            actionName: 'view'
                        }
                    })
                    break;
                case 'edit':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: rowId,
                            actionName: 'edit'
                        }
                    })
                    break;
           }
        
       }
       
       //Add Options to Sort By ComboBox
       sortByPicklistValue() {
           for(let option in this.columns){ 
               if(this.columns[option].sortable){
                   this.sortOptions.push({
                       label : this.columns[option].label,
                       value : this.columns[option].fieldName,
                   });
               }
           }
           if(this.sortOptions.length > 0){
               this.isSortable = true;
           }
       }

       
       //Sort By change Handler
       sortByhandleChange(event){
           this.sortByField = event.detail.value;
           this.onHandleSorting(); 
       }
   
       
       //on Handle sorting
       onHandleSorting() {
           this.isLoaded = true
           const { fieldName: sortedBy, sortDirection } = {"fieldName":this.sortByField,"sortDirection":this.sortDirection};
           
           let tableRows = this.filteredData.map(data=>{
               return data.detail.tableRows
           })


          
           let finaltableRows = tableRows.map(row=>{
               let id = ''
               let rowMap =  row.map(obj=>{
                   id = obj.Id
                   return {...obj.fieldAndItsValue,Id: id}
               })
               return Object.assign({}, ...rowMap)
           })
           let cloneData = [...finaltableRows];
           cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
           this.records = cloneData;
           //reseting
           cloneData = [];
           finaltableRows=[];
           this.sortDirection = sortDirection;
           this.sortedBy = sortedBy;
           this.wrapperColumnsAndRecords(this.records);
           this.sortDirection = this.sortDirection === 'asc'?'desc':'asc';
           
           this.isLoaded = false
          
       }

       sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

       //Show Sort ICON
       get disableSortIcon(){
            return !this.sortByField || !this.filteredData.length;
       }

       //Change sort Icon based on sort Direction
       get sortIcon(){
           return  this.sortDirection === 'desc' ? 'utility:arrowup' : 'utility:arrowdown'
       }

       //if No Data,Disable Sort By Field
       get disableSortBy(){
           return !this.filteredData.length
       }
   
       handleSelectedRecord(event){
            //get the slds-item class
            let target = this.template.querySelector(`[data-id="${event.target.dataset.record}"]`);
            
            // checking the count to enable button, add selected class, add the value to selectedRecords
            if(event.target.checked ){
                this.checkedCount += 1;
                target.classList.add('selected');
                this.selectedRecords.push(event.target.dataset.record);
            }
            else{   
                this.checkedCount -=1;
                target.classList.remove('selected');
                this.selectedRecords.pop(event.target.dataset.record);            
            }
            this.showCustomButton = this.checkedCount > 0 ? true: false  
            console.log('selected Ids')
            console.log(JSON.stringify(this.selectedRecords));
            //Dispatcing Selected Id's to parent component
            this.dispatchEvent(new CustomEvent("rowselection",{
                detail : this.selectedRecords,
            }
            ));
   
       }
       
       filterbyHandler(event){ //filter ComboBox Handler
         this.filterBy = event.target.value
         this.isLoaded=true
         this.filter(this.searchKey);
         this.isLoaded=false
       }

       filterHandler(event){ //Filter value change Handler
         this.searchKey = event.target.value
         this.isLoaded = true
         this.filter(this.searchKey)
         this.isLoaded = false
       }

       filter(key){
        window.clearTimeout(this.timer)
        if(key){
           this.timer = window.setTimeout(()=>{
                this.filteredData = this.resultData.filter(data=>{
                    if(this.filterBy ==='All'){
                       return  data.detail.tableRows.some(row=>{
                           return row.value.toString().toLowerCase().includes(key.toLowerCase())
                       })  
                    }else{
                        return  data.detail.tableRows.some(row=>{
                           const val = row[this.filterBy] ? row[this.filterBy] : '' 
                           return val.toString().toLowerCase().includes(key.toLowerCase())
                       })  
                    }                   
                })
            },DELAY)
            
        }else{
            this.wrapperColumnsAndRecords(this.originalRecords)
        }
       }
}