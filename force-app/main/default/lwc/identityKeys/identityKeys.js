import { LightningElement, track, api } from 'lwc';
import getUnifiedIdentityKeysSearchList from '@salesforce/apex/UnifiedContactIdentityKeysController.getUnifiedIdentityKeysSearchList';



const columns = [
    // { label: 'Id', fieldName: 'Id', type: 'text', sortable: true},
    { label: 'Address Line 1', fieldName: 'AddressLine1', type: 'text'},
];    


export default class IdentityKeys extends LightningElement {
    
    columns = columns;
    errorMsg;
    @track appLabel='Identity Keys';
    @track customerId = '';
    @track isLoading = false;
    @track identityKeysList;
    @track addressLine1 = '';
    @track addressLine2 = '';
    @track city = '';
    @track state = '';
    @track postalCode = '';
    @track country = '';

    customerSelected(event) {
        this.isLoading = true;
        const unifiedCustomerId = event.detail;
        console.log('customer id ' , unifiedCustomerId);
        this.customerId = unifiedCustomerId;
        console.log('Invoking ... ' , 'getUnifiedIdentityKeysSearchList -> Start');
        getUnifiedIdentityKeysSearchList({searchParam : this.customerId})
        .then((data) => {
            this.isLoading = !this.isLoading;
            console.log('raw data', data);
            this.identityKeysList = data;

            this.addressLine1 = data[0].AddressLine1;
            this.addressLine2 = data[0].AddressLine2;
            this.city = data[0].City;
            this.state = data[0].State;
            this.postalCode = data[0].PostalCode;
            this.country = data[0].Country;                                                            
            
            console.log('html datatable : ', this.identityKeysList);
            console.log('Address Line 1 : ', this.addressLine1);
            console.log('Completed ... ' , 'getUnifiedIdentityKeysSearchList -> End');            
        })
        .catch((error) => {
            this.errorMsg = error;
        });

    }    
}