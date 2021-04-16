import { LightningElement ,wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSegmentMemberships from '@salesforce/apex/SegmentMembershipController.getSegmentMemberships';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class SegmentMembership extends NavigationMixin(LightningElement) {
    channelName = '/event/C360_Event__e';
    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;

    @track columns = [{
        label: 'Product',
        fieldName: 'Segment_Name__c',
        type: 'text'
    }];
    @track segmentName;
    @track segmentMembershipList ;
    @track notifier;
    url;

    connectedCallback() {
        this.recentSegmentMembershipPageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'C360_Segment_Membership__c',
                actionName: 'home'
            }
        };
        this[NavigationMixin.GenerateUrl](this.recentSegmentMembershipPageRef)
            .then(url => this.url = url); 
        
        this.getData();
        //subscribe to events
        this.handleSubscribe();            
        // Register error listener       
        this.registerErrorListener(); 
    }

    // @wire(getSegmentMemberships)
    // wiredSegmentMembershipList({
    //     error,
    //     data
    // }) {
    //     if (data) {
    //         console.log(data);
    //         this.segmentName = data[0].Segment_Name__c;
    //         this.segmentMembershipList = data;
    //     } else if (error) {
    //         this.error = error;
    //     }
    // } 
    
    handleClick(evt) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        evt.preventDefault();
        evt.stopPropagation();
        // Navigate to the Account Home page.
        this[NavigationMixin.Navigate](this.recentSegmentMembershipPageRef);
    }  
    
    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback =  (response) => {
            console.log('Segment Membership PE fired: ', JSON.stringify(response));
            // Response contains the payload of the new message received
            this.notifier = JSON.stringify(response);
            // refresh LWC
            this.getData();


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

    getData() {
        getSegmentMemberships()
            .then((data) => {
                if (data) {
                    console.log('segment data : ' + new Date(), JSON.stringify(data));
                    this.segmentName = data[0].Segment_Name__c;
                    this.segmentMembershipList = data;
                }
            })
            .catch((error) => {
                    this.error = error;
            })            
    }
}