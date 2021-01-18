import { LightningElement, track, api, wire } from 'lwc';
import getUnifiedIdentityKeysSearchList from '@salesforce/apex/UnifiedContactIdentityKeysController.getUnifiedIdentityKeysSearchList';
import { NavigationMixin } from 'lightning/navigation';
import { MessageContext, createMessageContext, releaseMessageContext, publish, subscribe, unsubscribe } from 'lightning/messageService';
import SAMPLEMC from "@salesforce/messageChannel/CustomerMessagingChannel__c";

const columns = [
    // { label: 'Id', fieldName: 'Id', type: 'text', sortable: true},
    { label: 'Address Line 1', fieldName: 'AddressLine1', type: 'text'},
];    


export default class IdentityKeys extends NavigationMixin(LightningElement) {
    
    columns = columns;
    errorMsg;
    @track appLabel='Identity Keys';
    @track customerRecord = '';
    @track customerId = '';
    @track isLoading = false;
    @track identityKeysList;
    @track addressLine1 = '';
    @track addressLine2 = '';
    @track city = '';
    @track state = '';
    @track postalCode = '';
    @track country = '';

    context = createMessageContext();

    customerSelected(event) {
        this.isLoading = true;
        const unifiedCustomerId = event.detail.Id;
        const unifiedCustomerFName = event.detail.FirstName;
        console.log('customer id ' , unifiedCustomerId);
        console.log('customer firstname 1 ' , unifiedCustomerFName);
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
            this.customerRecord = JSON.parse(this.createJSONPayLoad(
                        event.detail.Id, event.detail.FirstName, 
                        event.detail.LastName, 
                        this.addressLine1, this.addressLine2, this.city, 
                        this.state, this.postalCode, this.country, 
                        event.detail.EmailAddress, event.detail.Telephone,
                        event.detail.LoyaltyPoints, event.detail.LoyaltyStatus)
                    );
            
            console.log('customer record ', JSON.stringify(this.customerRecord));
            this.navigatetoDetails();

        })
        .catch((error) => {
            this.errorMsg = error;
        });

    }  
    
    navigatetoDetails() {
        console.log('navigation', 'navigating');

        let compDefinition = {
            componentDef: "c:customerProfile",
            attributes: {
                ParentMessage : this.customerId != '' ? this.customerRecord : "No Id"
            }
        };

        // Base64 encode the compDefinition JS object
        let encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedCompDef
            }
        });        

        // this.publishMC();
        // // Navigate to a specific CustomTab.
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__navItemPage',
        //     attributes: {
        //         // CustomTabs from managed packages are identified by their
        //         // namespace prefix followed by two underscores followed by the
        //         // developer name. E.g. 'namespace__TabName'
        //         apiName: 'C360'
        //     }
        // });        
    }

    publishMC() {
        
        const message = {
            recordId: this.customerId,
            recordData: { value: this.customerId }
        };
        console.log('Identity keys before publishing ...', JSON.stringify(message));
        publish(this.context, SAMPLEMC, message);
        console.log('Identity keysd after publishing ...', JSON.stringify(message));
    }

    subscribeMC() {
        console.log('Identity keys subscribeMC...before', this.subscription);
        if (this.subscription) {
            console.log('Identity keys subscribeMC this.subscription is not null', 'returning');
            return;
        }
        this.context = createMessageContext();
        console.log('Identity keys subscribeMC this.subscription...1', this.subscription);
        this.subscription = subscribe(this.context, SAMPLEMC, (message) => {
            console.log('Identity keys subscribeMC this.subscription....after', this.subscription);
            this.handleMessage(message);
        },{
            scope: APPLICATION_SCOPE
        });
     }
    
     unsubscribeMC() {
         unsubscribe(this.subscription);
         this.subscription = null;
     }    

    disconnectedCallback() {
        console.log('releasing message context');
        releaseMessageContext(this.context);
    }
    
    createJSONPayLoad(id, firstname, lastname, addr1, addr2, city, state, postalcode, 
                        country, email, phone, LoyaltyStatus, LoyaltyPoints ) {
        let customer = new Object();
        customer.Id = id;
        customer.FirstName = firstname;
        customer.LastName = lastname;
        customer.Address1 = addr1;
        customer.Address2 = addr2;
        customer.City = city;
        customer.State = state;
        customer.PostalCode = postalcode;
        customer.Country = country;
        customer.Email = email;
        customer.Phone = phone;
        customer.LoyaltyPoints = LoyaltyPoints;
        customer.LoyaltyStatus = LoyaltyStatus;

        return JSON.stringify(customer);
    }
}