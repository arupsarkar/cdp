import { LightningElement, track, api, wire } from 'lwc';
import { MessageContext, 
    APPLICATION_SCOPE,
    createMessageContext, 
    releaseMessageContext, 
    publish, 
    subscribe, 
    unsubscribe } from 'lightning/messageService';
import SAMPLEMC from "@salesforce/messageChannel/CustomerMessagingChannel__c";
import getSalesOrders from '@salesforce/apex/SalesOrderController.getSalesOrders';

export default class CustomerProfile extends LightningElement {

    context = createMessageContext();
    @track subscription = null;
    @track receivedMessage = 'customer id';
    @api ParentMessage = '';
    @track customerRecord = '';
    @track salesorderRecord = '';
    @track errorMsg = '';
    @track LifeTimeSpend = '';
    @track LifeTimeOrders = '';
    @track AvgOrderAmount = '';

    connectedCallback() {
        console.log('connected callback initiated ...', this.ParentMessage.Id);
        this.subscribeMC();
        getSalesOrders({searchParam : this.ParentMessage.Id})
        .then((data) => {
            console.log('sales data', data);
            this.LifeTimeSpend = data[0].ltvSpend;
            this.LifeTimeOrders = data[0].ltvOrders;
            this.AvgOrderAmount = data[0].avgOrderAmount;
        })
        .catch((error) => {
            this.errorMsg = error;
        });        
    }    
    

    

    subscribeMC() {
        console.log('C360 this.subscription...before', this.subscription);
        if (this.subscription) {
            console.log('C360  this.subscription is not null', 'returning');
            return;
        }
        this.context = createMessageContext();
        console.log('C360  this.subscription...1', this.subscription);
        this.subscription = subscribe(this.context, SAMPLEMC, (message) => {
            console.log('C360  this.subscription....after', this.subscription);
            this.handleMessage(message);
        },{
            scope: APPLICATION_SCOPE
        });
     }
    
     unsubscribeMC() {
         unsubscribe(this.subscription);
         this.subscription = null;
     }
  
     handleMessage(message) {
         console.log('C360  payload...', JSON.stringify(message, null, '\t'));
         //this.receivedMessage = message ? JSON.stringify(message, null, '\t') : 'no message payload';
         this.receivedMessage = message.recordId;
         console.log('C360 received payload 1...', this.receivedMessage); 
         console.log('C360 received payload 2...', message.recordData.value);                  
     }
  
     get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }

     disconnectedCallback() {
         releaseMessageContext(this.context);
     }    
}