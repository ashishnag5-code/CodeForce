import { LightningElement, api } from 'lwc';

export default class Pagination extends LightningElement {
    currentPage =1
    totalRecords
    @api recordSize = 5
    totalPage = 0
    get records(){
        return this.visibleRecords
    }
    @api 
    set records(data){
        if(data){ 
            this.totalRecords = data
            console.log('totalRecords'+JSON.stringify(this.totalRecords));
            this.recordSize = Number(this.recordSize)
            this.totalPage = Math.ceil(data.length/this.recordSize)
            if(this.totalPage < 1){
                this.currentPage = 0;
            }
            else{
                this.currentPage = 1;
            }
            this.updateRecords()
        }
    }

    get disablePrevious(){ 
        return this.currentPage<=1
    }
    get disableNext(){ 
        return this.currentPage>=this.totalPage
    }
    previousHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1
            this.updateRecords()
        }
    }
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1
            this.updateRecords()
        }
    }
    updateRecords(){ 
        const start = (this.currentPage-1)*this.recordSize
        const end = this.recordSize*this.currentPage
        console.log('%%% '+this.totalRecords);
        if(this.totalRecords != undefined && this.totalRecords != true){
            this.visibleRecords = this.totalRecords.slice(start, end)
            this.dispatchEvent(new CustomEvent('paginate',{ 
                detail:{ 
                    records:this.visibleRecords
                }
            }))
        }
    }
}