({
	doInit : function(component, event, helper) {
        debugger;
         helper.fetchNPAData(component, event, helper);
	},
   
    //Method gets called by onsort action,
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);    
    },
    
    redirectToDetailPage: function (component, event, helper) {
        debugger;
        var fieldName = event.target;
          
    }
    
})