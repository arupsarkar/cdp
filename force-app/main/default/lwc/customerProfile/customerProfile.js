import { LightningElement, track, api, wire } from 'lwc';
import getSalesOrders from '@salesforce/apex/SalesOrderController.getSalesOrders';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class CustomerProfile extends LightningElement {

    // context = createMessageContext();
    @track showPhoneData = true;
    @track showEmailData = true;
    @track showAddressData = true;
    @track subscription = null;
    @track receivedMessage = 'customer id';
    @api ParentMessage = '';
    @track customerRecord = '';
    @track salesorderRecord = '';
    @track errorMsg = '';
    @track LifeTimeSpend = '';
    @track LifeTimeOrders = '';
    @track AvgOrderAmount = '';
    @track HighestOrderAmount = '';
    @track LowestOrderAmount = '';
    @track createdDate = new Date();
    @track updatedDate = new Date();
    @track refresh;
    unifiedId = '';
    channelName = '/event/C360_Event__e';

    connectedCallback() {
        console.log('LTV connected callback initiated ...', this.ParentMessage.Id);
        this.unifiedId = this.ParentMessage.Id;
        this.refresh = false;
        console.log('Starting to subscribe to platform event in customer profile LTV - Start');
        //subscribe to events
        this.subscribeToPlatformEvent();            
        console.log('Starting to subscribe to platform event in customer profile LTV - End');
        console.log('Starting to error listener in customer profile LTV - Start');
        // Register error listener       
        this.registerPlatformEventErrorListener();              
        console.log('Starting to error listener in customer profile LTV - End');        
        this.createdDate = ((this.createdDate.getMonth() > 8) ? (this.createdDate.getMonth() + 1) : ('0' + (this.createdDate.getMonth() + 1))) + '/' + ((this.createdDate.getDate() > 9) ? this.createdDate.getDate() : ('0' + this.createdDate.getDate())) + '/' + this.createdDate.getFullYear();
        // this.subscribeMC();
        console.log('phone ...', this.ParentMessage.Phone);
        console.log('email ...', this.ParentMessage.Email);
        console.log('address ...', this.ParentMessage.Address1);        
        // check for showing data on or off
        if(!this.ParentMessage.Phone) {
            this.showPhoneData = false;
        }
        if(!this.ParentMessage.Email) {
            this.showEmailData = false;
        }
        if(!this.ParentMessage.Address1 && !this.ParentMessage.PostalCode) {
            this.showAddressData = false;
        }

    }    
    
    getLTVData(searchData) {
        getSalesOrders({searchParam : searchData})
        .then((data) => {
            console.log('LTV data', data);
            this.LifeTimeSpend = data[0].ltvSpend;
            this.LifeTimeOrders = data[0].ltvOrders;
            this.AvgOrderAmount = data[0].avgOrderAmount;
            this.HighestOrderAmount = data[0].highestOrderAmount;
            this.LowestOrderAmount = data[0].lowestOrderAmount;
        })
        .catch((error) => {
            this.errorMsg = error;
        });  
    }
    
    // Handles subscribe button click
    subscribeToPlatformEvent() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log('LTV message callback ', JSON.stringify(response));
            console.log(new Date(), '------- LTV payload start------');
            console.log(response.data.payload.Category__c);
            this.refresh = true;
            if(response.data.payload.Category__c == 'LTV') {
                console.log(new Date(), '------- before LTV refresh start------' + this.refresh);
                this.getLTVData(this.unifiedId);
                console.log(new Date(), '------- after LTV refresh start------' + this.refresh);
            }
            
            
            console.log(new Date(), '------- LTV payload end ------');
            // Response contains the payload of the new message received

        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('LTV Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
    
    registerPlatformEventErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('LTV Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }      
}