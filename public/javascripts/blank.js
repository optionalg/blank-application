$(document).ready(function () {	
	
    wasVisible = new Boolean(false);
	
    $('a.menuDropButton').click(function(){
        wasVisible = false;
		
        if ($(this).next('div.subMenu').is(":visible")){
            wasVisible = true;
        }
		
        $('.subMenu:visible').each(function(){
            $(this).css("display","none")
        });
		
        if (wasVisible == false) {
            $(this).next('div.subMenu').css("display", "block");
            $(this).next('div.subMenu').corner("bottom");
        }
    });
	

    $('.munuElement').hover(
        function () {
            $(this).stop().animate({
                paddingRight: "25px"
            }, 200);
        },
        function () {
            $(this).stop().animate({
                paddingRight: "15px"
            });
        }
        );
	
    $('.filter').click(function(){
        $(this).next('ul.ddown').slideToggle('fast');
    });
    
    $('.auto-submit-star').rating({
        callback: function(value, link){
            var url = $("#submit_rating").attr("action");
            $.ajax({
                type: "POST",
                url :url,
                data: "rated="+value,
                success: function(){
                    $('input').rating('readOnly',true)
                    alert("Your Rate Has Been Saved");
                }

            });
        }
    });

});

function autocomplete_on(array, div){

    if(div == '#keyword_value'){
        $(div).autocomplete(array);
    }
    
    if (div == '#user_login'){
        $(div).autocomplete(array,{
            minChars: 0,
            width: 310,
            matchContains: "word",
            autoFill: false,
            formatItem: function(row, i, max) {
                return row.login + "[" + row.name + "]" + "[" + row.email + "]";
            },
            formatMatch: function(row, i, max) {
                return row.login + " " + row.name + " " + row.email;
            },
            formatResult: function(row) {
                return row.login;
            }
        });
    }
}


function classify_bar(div,url) {
    $.ajax({
        type: 'GET',
        url: url,
        success: function(html){
            $(div).html(html);
        }
    });
}

//display the good tiem in a item list, google way of displaying.
function toggleAccordion(idClicked){
    var items_length = document.getElementById("total_items").value;
    for (var i=0 ; i < items_length ; ++i){
        var item_element = document.getElementById("itemInformations_"+i);
        if ("itemInformations_"+i != idClicked){
            item_element.style.display = 'none';
            item_element.parentNode.className = 'item_in_list';
        }else{
            if(item_element.style.display == 'none'){
                item_element.style.display = '';
                item_element.parentNode.className = 'selected_item_in_list';
            }else{
                item_element.style.display = 'none';
                item_element.parentNode.className = 'item_in_list';
            }
        }
    }
}

function add_new_user(url){
    //    alert('hello');
    //    alert(url);
    var user_login = $('#user_login').val();
    var role_id = $('#user_role').val();
    //alert($("#workspace_user_" + user_login)[0]);
    //alert(role_id);
    //alert(user_login);
    if(user_login != 0){
        if($("#workspace_user_" + user_login)[0] == null){
            $.ajax({
                type: 'GET',
                url: url,
                data: "user_login="+user_login+"&role_id=" + role_id,
                dataType: "script"
            });
        }else{
            alert("Existing");
        }
        $('#user_login').val('');
    }

}

function show_people(workspace_id){
    var start_with = $('#start_with').val();
    var group_id = $('#group_id').val();
    var url = "/admin/workspaces/"+workspace_id+"/groups/filtering_contacts/";
    $.ajax({
        type: 'GET',
        url: url,
        data: "start_with="+start_with+"&group_id="+group_id,
        dataType: "script"
    });
}

function selectAll(chkObj,id){
    var multi=document.getElementById(id);
    if(chkObj)
        for(i=0;i<multi.options.length;i++)
            multi.options[i].selected=true;
    else
        for(i=0;i<multi.options.length;i++)
            multi.options[i].selected=false;
}

function selectItemTab(idSelected){
		
    // get the tabs links on witch we should change the class
    var tabsElements = document.getElementById('tabs').getElementsByTagName('li');
		
    for (var i = 0 ; i < tabsElements.length ; ++i){
        if (tabsElements[i].id == idSelected){
            tabsElements[i].className = 'selected';
        }
        else{
            tabsElements[i].className = '';
        }
    }
}

function insert_keyword(model_name, place, field_name){
    var name = $('#keyword_value').val();
    var key_words = name.split(',')
    for(var i=0; i < key_words.length; i++){
        var name = key_words[i].replace(/(^\s+|\s+$)/g, "");
        if(name != 0 && name.length == (name.replace(/<(\S+).*>(|.*)<\/(\S+).*>|<%(.*)%>|<%=(.*)%>+/g, "")).length){
            var hidden_field = "<input type='hidden' id='"+model_name+"_"+field_name+"' value='"+name+"' name='"+model_name+"["+field_name+"][]'>";
            $(place).append("<div id='"+name+"_000' class='keyword_label'>"+hidden_field+name+"<a href='#' onclick='$(\"#" + name + "_000\").remove(); return false;'>X</a></div>")
        }
        $('#keyword_value').val('');
    }
}

function add_reply(parent){
    if($('#reply')){
        $('#reply_overlay').css('display', 'block');
        $('#reply').css('display','block');
        $('#comment_parent_id').val(parent);
    }
}


// to move option value from one select box to another select box
function shiftRight(removeOptions,addOptions,saveFlag)
{
    var availableOptions = document.getElementById(removeOptions);
    var assignedOptions = document.getElementById(addOptions);
    var selcted_Options = new Array();
    for(i=availableOptions.options.length-1;i>=0;i--)
    {
        if(availableOptions.options[i].selected){
            var optn = document.createElement("OPTION");
            optn.text = availableOptions.options[i].text;
            optn.value = availableOptions.options[i].value;
            assignedOptions.options.add(optn);
            availableOptions.remove(i);
        }else{
            selcted_Options.push(availableOptions.options[i].value);
        }
    }

    document.getElementById('selected_Options').value = selcted_Options
}
function shiftLeft(removeOptions,addOptions,saveFlag)
{
    var availableOptions = document.getElementById(removeOptions);
    var assignedOptions = document.getElementById(addOptions);
    var selcted_Options = new Array();
    for (i=0;i<assignedOptions.options.length; i++){
        selcted_Options.push(assignedOptions.options[i].value);
    }
    for (i=0; i<availableOptions.options.length; i++){
        if (selcted_Options.indexOf(availableOptions.options[i].value) <0 && availableOptions.options[i].selected) {
            selcted_Options.push(availableOptions.options[i].value);
            var optn = document.createElement("OPTION");
            optn.text = availableOptions.options[i].text;
            optn.value = availableOptions.options[i].value;
            assignedOptions.options.add(optn);
        }
    }
    for(i=availableOptions.options.length-1;i>=0;i--)
    {
        if(availableOptions.options[i].selected)
            availableOptions.remove(i);
    }
    document.getElementById('selected_Options').value = selcted_Options;
}

