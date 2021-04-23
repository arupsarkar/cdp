import { LightningElement, track } from 'lwc';

export default class Playground extends LightningElement {
    @track LifeTimeSpend = 2000;
    @track LifeTimeOrders = 134;
    @track AvgOrderAmount = 443;
    @track HighestOrderAmount = 2490;
    @track LowestOrderAmount = 39;    
}