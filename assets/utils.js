    function parseIsoDatetime(dtstr) {
        var dt = dtstr.split(/[: T-]/).map(parseFloat);
        return new Date(dt[0], dt[1] - 1, dt[2], dt[3] || 0, dt[4] || 0, dt[5] || 0, 0);
    }
    
    function getDate(s){    //parsing qui perchè js è local aware, qt no..
        if (s!=null){
        	var d = new Date(s);
        	var min = d.getMinutes().toString();
        	if (min < 10)
        		min = "0" + min;
        	return d.getDate() +"/"+ parseInt(d.getMonth()+1) +"/"+ d.getFullYear() +" "+  d.getHours() +":"+ min;
        }else return " ";
    }
    
    function getDateFromPicker(dtpicker){
        var x = dtpicker.value.getDate()+"-"+(parseInt(dtpicker.value.getMonth())+1)+"-"+dtpicker.value.getFullYear()+"T"+tmpicker.value.getHours()+":";
        if (tmpicker.value.getMinutes() < 10)
            x += "0" + tmpicker.value.getMinutes();
        else 
            x += tmpicker.value.getMinutes();
        return x;
    }
    
    function getTime(s){
        var d = new Date(s);
        var min = d.getMinutes().toString();
        if (min < 10)
            min = "0" + min;
        return d.getHours()+":"+min;
    }
    
    function parseIsoDate(dtstr) {
        var dt = dtstr.split(/[: T-]/).map(parseFloat);
        var data = new Date(dt[0], dt[1] - 1, dt[2], dt[3] || 0, dt[4] || 0, dt[5] || 0, 0);
        return data.getDate() + "/" + (parseInt(data.getMonth()) + 1).toString() + "/" + data.getFullYear();
    }