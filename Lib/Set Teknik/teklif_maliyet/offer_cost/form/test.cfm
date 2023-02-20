function money_control(){
    var i=1;
    var selected_groups=[];
    var totalRowCount = table.rows.length;
    for(i=1;i<=totalRowCount;i++){
        group_name_=document.getElementById("row_group_name"+i).value;
        selected_groups.push(group_name_);
    }        
    console.table(group_name_);
    const selected_money_=document.getElementById('money'+i).value;
    alert("test 1");
    return false;
}
    add_function="money_control()


