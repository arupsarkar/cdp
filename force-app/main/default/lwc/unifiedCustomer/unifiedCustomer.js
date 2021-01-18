import { LightningElement, wire, api, track } from 'lwc';
import getUnifiedIndividualList from '@salesforce/apex/UnifiedCustomerController.getUnifiedIndividualList';
import getUnifiedIndividualSearchList from '@salesforce/apex/UnifiedCustomerController.getUnifiedIndividualSearchList';
// import fetchDataHelper from './fetchDataHelper';


const actions = [
    { label: 'Show details', name: 'show_details' },
    // { label: 'Delete', name: 'delete' },
];

const columns = [
    // { label: 'Id', fieldName: 'Id', type: 'text', sortable: true},
    { label: 'First Name', fieldName: 'FirstName', type: 'text', sortable: true},
    { label: 'Last Name', fieldName: 'LastName', type: 'text', sortable: true},
    { label: 'Phone', fieldName: 'Telephone', type: 'phone'},
    { label: 'Email', fieldName: 'EmailAddress', type: 'email'},
    // { label: 'Loyalty Points', fieldName: 'LoyaltyPoints', type: 'text'},
    // { label: 'Tier', fieldName: 'LoyaltyStatus', type: 'text'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];    

export default class UnifiedCustomer extends LightningElement {

    columns = columns;
    errorMsg;
    constructor(){
        super();
    }
    strSearchIndividualLastName = '';
    strSearchIndividualFirstName = '';
    @track isLoading = true;
    record = {}
    @track individualList;
    @wire(getUnifiedIndividualList)
    data({error,data}) {
        if(data){
            this.isLoading = !this.isLoading;
            console.log('Log Data:');
            console.log('raw data', data);
            //console.log(JSON.parse(data).message, null, '\t');
            this.individualList = data;
            console.log('html data 4', this.individualList);

        } else if(error){
            console.log('Activity Error');
            this.errorMsg = error;
            console.log(error);
        } else{
            console.log('Sorry Nothing Happened');
        }
    } 

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }  
    
    showRowDetails(row) {

        console.log('>>> record : ', row.Id);
        this.record = row;
        console.log('this.record firstname : ', this.record.FirstName);
        console.log('this.record status : ', this.record.LoyaltyStatus);
        console.log('this.record points : ', this.record.LoyaltyPoints);
        // Creates the event with the unified customer ID data.
        const selectedEvent = new CustomEvent('customerselected', { detail: this.record });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);        
    }    

    handleIndividualName(event) {
        this.strSearchIndividualLastName = event.detail.value;
    }  
    handleIndividualFirstName(event) {
        this.strSearchIndividualFirstName = event.detail.value;
    }  

    handleSearch() {
        this.isLoading = true;
        if(!this.strSearchIndividualLastName) {
            this.errorMsg = 'Please enter last name to search.';
            this.individualList = undefined;
            return;
        }    
        
        getUnifiedIndividualSearchList({searchParam : this.strSearchIndividualLastName, searchParam2: this.strSearchIndividualFirstName})
        .then((result) => {
            this.isLoading = !this.isLoading;
            this.individualList = result;
        })
        .catch((error) => {
            this.individualList = undefined;
            if(error) {
                this.errorMsg = error.body.message;
            } 
        });
    }

}