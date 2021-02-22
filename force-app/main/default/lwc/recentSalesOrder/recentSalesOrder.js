import { LightningElement,wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRecentSalesOrders from '@salesforce/apex/RecentSalesOrderController.getRecentSalesOrders';

export default class RecentSalesOrder extends NavigationMixin(LightningElement) {


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
    @track error;
    @track salesOrderList ;

    url;

    connectedCallback() {
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
    }


    @wire(getRecentSalesOrders)
    wiredSalesOrdersList({
        error,
        data
    }) {
        if (data) {
            console.log(data);
            this.productName = data[0].Product_Name__c;
            this.productPrice = data[0].Sale_Price_Amount__c;
            this.purchaseDate = data[0].Purchase_Order_Date__c;
            this.salesOrderList = data;
        } else if (error) {
            this.error = error;
        }
    }

    handleClick(evt) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        evt.preventDefault();
        evt.stopPropagation();
        // Navigate to the Account Home page.
        this[NavigationMixin.Navigate](this.recentSalesOrderPageRef);
    }    

}