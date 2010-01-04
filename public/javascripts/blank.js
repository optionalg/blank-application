//this line is for recognison of ajax method. cf rails cast 136!
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

$(document).ready(function () {	
	
    wasVisible = new Boolean(false);
	
	//General menu, script for uniqueness of visible element.
    $('a.menuDropButton').click(function(){
        wasVisible = false;
		
        if ($(this).next('div.subMenu').is(":visible")){
            wasVisible = true;
        }
		
        $('.subMenu:visible').each(function(){
            $(this).css("display","none");
        });
		
        if (wasVisible == false) {
            $(this).next('div.subMenu').css("display", "block");
        }
    });
	
	//Effect on tabs on mouse over.
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
	
	//Filter drop down in item list.
    $('.filter').live("click", function(){
		var self = $(this);
        self.next('ul.ddown').slideToggle('fast');
    });
	
	//Modal Box for footer reply
	$(".commentfooterReply").live('click',function(){
		$('#commentReply #comment_parent_id').val($(this).attr("id"));
		$.fn.colorbox({width:"660px", inline:true, href:"#commentReply"});
	});

	//RATING SYSTEM
    $('.auto-submit-star').rating({
        callback: function(value, link){
            var url = $("#submit_rating").attr("action");
            $.ajax({
                type: "POST",
                url :url,
                data: "rated="+value,
                success: function(){
                    $('input').rating('readOnly',true)
                    $('#notice').html("Your Rating Has Been Registered");
                    $('#notice').css('display', 'block');
					$('#notice').animate({opacity: 1}, 3000, function(){$(this).fadeOut('fast')});
                }
            });
        }
    });


	//HINT FOR FORMS && AJAX VALIDATION
	$(".formElement input").focus( function() {	
		$(this).nextAll('.ajax_hint_message').css('display','inline');
	});
	$(".formElement textarea").focus( function() {	
		$(this).nextAll('.ajax_hint_message').css('display','inline');
	});
	$(".formElement input").blur( function(){
		$(this).displayHintForField();
	});
	
	$(".formElement textarea").blur( function(){
		$(this).displayHintForField();
	});
	
	$('#container').find('#notice').animate({opacity: 1}, 3000, function(){$(this).fadeOut('fast')});
	
	$('#error_closing').live('click', function(){
		$('#error').fadeOut('fast');
	});
	
	$(".deleteLink").live('click', function(){
		var modalId = $(this).attr('modal_id')
		$.fn.colorbox({width:"300px", inline:true, href:modalId});
	});
	
	$(".deleteClose").click(function(){
		$.fn.colorbox.close();
	});

	$('#fck_insert_image').colorbox({width:"600px", inline:true, href:"#insert_images"});
	$('#fck_insert_link').colorbox({width:"600px", inline:true, href:"#insert_link"});
	$('#fck_insert_video').colorbox({width:"600px", inline:true, href:"#insert_video"});
	$('#fck_insert_audio').colorbox({width:"600px", inline:true, href:"#insert_audio"});
	
	$('#images_tabs').tabs();
	$('#insert_link').tabs();
	
	$('#insert_image a').live('click', function(){
		stringToInsert = '<img src="' + $(this).attr("picSrc") +'" ';
		if ($('#image_align').val() != ""){
			stringToInsert += 'align="' + $('#image_align').val() +'" ';
		}
		if ($('#image_width').val() != "" && !isNaN($('#image_width').val())){
			stringToInsert += 'width="' + $('#image_width').val() + 'px" '; 
		}
		stringToInsert +=  + '"/>'
		
		$('#image_align').val("");
		$('#image_width').val("");
		
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});
	
	
	$('.item_list a').live('click', function(){
		stringToInsert = '';
		
		if (CKEDITOR.instances.ckInstance.getSelection().getNative() != ""){
			stringToInsert += '<a href="' + $(this).attr('itmUrl') + '">';
			stringToInsert += CKEDITOR.instances.ckInstance.getSelection().getNative();
			stringToInsert += '</a>';
		}
		
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});
	
	
	$('#insert_video a').live('click', function(){
		
		stringToInsert = '<embed ';
		if ($('#player_width').val() != "") {
			stringToInsert += 'width="' + ('#player_width').val() +'" '; 
		}else{
			stringToInsert += 'width="370" '; 
		}
		if ($('#player_height').val() != "") {
			stringToInsert += 'height="' + ('#player_height').val() +'" '; 
		}else{
			stringToInsert += 'height="257" '; 
		}
		
		stringToInsert +='flashvars="&image=' + $(this).attr('itmUrl') + '/2.png&file=' + $(this).attr('itmUrl') +'/video.flv"';
		stringToInsert += 'allowfullscreen="true" allowscriptaccess="always" quality="high" src="/players/videoplayer.swf" type="application/x-shockwave-flash"/>';
				
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});

	$('#insert_audio a').live('click', function(){
		stringToInsert = '<embed allowfullscreen="true" allowscriptaccess="always" quality="high"';
		stringToInsert += ' flashvars="&playerID=1&soundFile=' + $(this).attr('itmUrl');
		stringToInsert += '" src="/players/audioplayer.swf" type="application/x-shockwave-flash"/>';
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});
	
	
	// ************************************************************
	// When keyword field got focus, submit is disable, user can add
	// Keyword by pressing enter.
	// When, keyword field loose focus, submit can be clicked
	// ************************************************************
	
	// $('form').submit(function(){
	// 	alert($('#submit_state').attr("disable"));
	// });
	// 
	// $('#keyword_value').focus(function(){
	// 	$('#submit_state').attr("disabled", "true");
	// 	alert($('#submit_state').attr("disable"));
	// });
	// 
	// $('#keyword_value').blur(function(){
	// 	$('#submit_state').removeAttr("disabled");
	// });
	// 
	// $('#keyword_value').keyup(function(e) {
	//     if(e.keyCode == 13) {
	//         insert_keyword($(this).next('a').attr('itemclass'),"#keywords_list", "keywords_field");
	//     }
	// })
});

function ajaxSaveOfFCKContent(){
	
	var url = $('#ajax_save_url').val();
	var itemId = $('#item_id').val();
	var body = CKEDITOR.instances.ckInstance.getData();
	
	//if item has been saved before (get an id... in wich you can save!!)
	if (itemId != ""){
		$.ajax({
	        type: "PUT",
	        url: url + itemId,
			data: 'content=' + body,
	        success: function(html){
				alert ('save ok');
	        }
	    });
	}
	else {
		alert('save first');
	}
}


jQuery.fn.displayHintForField = function(){
	//hide the hint message
	$(this).nextAll('.ajax_hint_message').css('display','none');
	//ajax validation called with attribute embeded in the input file
	var model = $(this).attr("itemclass");
	var attribute = $(this).attr("validate");
	var value = $(this).val();
	var inputConcerned = $(this);
	//lauch ajax validation on server for the current field
	$.ajax({
        type: "POST",
        url: $(this).attr("url"),
        data: "model="+model+"&attribute="+attribute+"&value="+value,
        success: function(html){
			element = "#hint_for_" + model + "_" + attribute;
			//if there is an error
			if (html != ""){
				//remove the previous error message
				$(element).find('.formError').remove();
				//add the new error message
				$(element).find('.hintMessage').append(html);
				//put red border on relative input
				$(inputConcerned).css('border', '1px solid red');
			}
			else{
				//remove the form error
				$(element).find('.formError').remove();
				//remove the red border
				$(inputConcerned).css('border', '1px solid #ccc');
			}
        }
    });
}

function imageUploadComplete(stringToInsert){
	CKEDITOR.instances.article_body.insertHtml(stringToInsert);
	$.fn.colorbox.close();
	$('#image_file').val("");
}

function saveFCKContentDraf(){
	alert('save');
}

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


function classify_bar(url) {
    $.ajax({
        type: 'GET',
        url: url,
		dataType: "script",
		success:function(html){
			
		}
    });
}

function translation_selection(array){
    for(i=0;i < array.length; i++){
        $("#"+array[i]).css('display','none');
        if(array[i] == 'select')
            return;
        else
            $("#"+array[i]).css('display','block');
    }
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
		$('#keyword_value').focus();
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

function add_new_follower(){
	//getting the mail value
    var email = $('#new_follower_email').val();
	//cleaning for jQuery to understand the div ID.
	var emailDivId = email.replace("@", "_");
	var emailDivId = emailDivId.replace(".", "_");
	
    if(email != 0){
		//creating a new div with ID, for deletion possible.
        var new_email = "<div id='" + emailDivId + "'>";
		new_email += email + " | <a onclick=\"$('#" + emailDivId + "').remove()\">DELETE</a>";
        new_email += "<input type='hidden' name='configuration[sa_exception_followers_email][]' value='"+email+"'></div>";

		//adding the mail to the follower list.
        $('#followers_email').append(new_email);
		//reseting form.
        $('#new_follower_email').value = '';
    }
}