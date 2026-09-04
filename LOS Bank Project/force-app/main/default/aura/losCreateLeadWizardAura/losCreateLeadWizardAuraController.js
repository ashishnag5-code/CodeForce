({
    //Defect Fix - W-000103 start
    handleCreateLeadRefreshChange: function(component, event, handler){
        $A.get('e.force:refreshView').fire();
    },
    onTabClosed: function(component, event, handler){
        console.log('%%% tab close');
    },
    reInit: function(component, event, handler){
        console.log('%%% tab reInit');
    }
    //Defect Fix - W-000103 end
})