/**
 * @File Name          : AccountTrigger.trigger
 * @Description        : 
 * @Author             : Roman Hnativ
 * @Group              : 
 * @Last Modified By   : Roman Hnativ
 * @Last Modified On   : 2/20/2020, 1:03:36 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/20/2020   Roman Hnativ     Initial Version
**/
trigger AccountTrigger on Account (before insert, after insert, before update, after update) {
    TriggerFactory.createHandler(Account.sObjectType);
}