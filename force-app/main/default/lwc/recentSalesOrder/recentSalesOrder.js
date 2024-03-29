import { LightningElement,wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRecentSalesOrders from '@salesforce/apex/RecentSalesOrderController.getRecentSalesOrders';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class RecentSalesOrder extends NavigationMixin(LightningElement) {

    channelName = '/event/C360_Event__e';
    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;    
    @track notifier;    
    @track columns = [{
            label: 'Product',
            fieldName: 'Product_Name__c',
            type: 'text',
            sortable: true
        },
        {   
            label: 'Product SKU',
            fieldName: 'ProductSKU__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Purchase Order Date',
            fieldName: 'Purchase_Order_Date__c',
            type: 'Date',
            sortable: true
        },
        {
            label: 'Amount',
            fieldName: 'Sale_Price_Amount__c',
            type: 'Currency',
            sortable: true
        }
    ];
    @track productName;
    @track productPrice;
    @track purchaseDate;
    @track imageLink;
    @track productURL;
    @track error;
    @track salesOrderList;
    @track refresh;
    @track productLogo = 'https://www.northerntrailoutfitters.com/on/demandware.static/-/Sites-nto-apparel/default/dwf9d82181/images/large/2050857ATT-0.jpg';
    url;

    connectedCallback() {

        this.refresh = false;
        // Store the PageReference in a variable to use in handleClick.
        // This is a plain Javascript object that conforms to the
        // PageReference type by including 'type' and 'attributes' properties.
        // The 'state' property is optional.
        this.recentSalesOrderPageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'C360_Recent_Sales_Order__c',
                actionName: 'home'
            }
        };
        this[NavigationMixin.GenerateUrl](this.recentSalesOrderPageRef)
            .then(url => this.url = url);

        this.getData();
        //subscribe to events
        this.handleSubscribe();            
        // Register error listener       
        this.registerErrorListener();             
    }

    getData() {
        getRecentSalesOrders()
            .then((data) => {
                if (data) {
                    console.log('recent sales order : ' + new Date(), JSON.stringify(data));
                    this.productName = data[0].Product_Name__c != undefined ? data[0].Product_Name__c : 'No Product';
                    this.productPrice = data[0].Sale_Price_Amount__c != undefined ? data[0].Sale_Price_Amount__c : '0.00';
                    this.purchaseDate = data[0].Purchase_Order_Date__c != undefined ? data[0].Purchase_Order_Date__c : 'No Date';
                    this.imageLink = data[0].Image_Link__c;
                    this.productURL = data[0].Product_URL__c;
                    this.salesOrderList = data;
                }
            })
            .catch((error) => {
                    this.error = 'Data not available';
                    this.salesOrderList = undefined;
                    console.log('Sales Order Error ---> ', error)
            });            
    }    

    handleClick(evt) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        evt.preventDefault();
        evt.stopPropagation();
        // Navigate to the Account Home page.
        this[NavigationMixin.Navigate](this.recentSalesOrderPageRef);
    }    


    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log('sales order: ', JSON.stringify(response));
            console.log(new Date(), '------- sales order payload start------');
            console.log(response.data.payload.Category__c);
            this.refresh = true;
            if(response.data.payload.Category__c == 'Sales Order') {
                console.log(new Date(), '------- before sales order refresh start------' + this.refresh);
                this.getData();
                console.log(new Date(), '------- after sales order refresh start------' + this.refresh);
            }
            //this.getData();
            console.log(new Date(), '------- sales order payload end ------');
            // Response contains the payload of the new message received
            this.notifier = JSON.stringify(response);

        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
            this.toggleSubscribeButton(true);
        });
    }

    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }
        
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }  
}