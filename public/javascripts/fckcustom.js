// CHANGE FOR APPS HOSTED IN SUBDIRECTORY
FCKRelativePath = '';

// DON'T CHANGE THESE
FCKConfig.LinkBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.ImageBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=Image&Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.FlashBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=Flash&Connector='+FCKRelativePath+'/fckeditor/command';

FCKConfig.LinkUploadURL = FCKRelativePath+'/fckeditor/upload';
FCKConfig.ImageUploadURL = FCKRelativePath+'/fckeditor/upload?Type=Image';
FCKConfig.FlashUploadURL = FCKRelativePath+'/fckeditor/upload?Type=Flash';
FCKConfig.SpellerPagesServerScript = FCKRelativePath+'/fckeditor/check_spelling';
FCKConfig.AllowQueryStringDebug = false;
FCKConfig.SpellChecker = 'WSC' ;	// 'WSC' | 'SpellerPages' | 'ieSpell'

//FCKConfig.Plugins.Add( 'easyUpload', 'es' ) ;		// easyUpload translated to spanish
FCKConfig.Plugins.Add( 'easyUpload', 'ja' ) ;

FCKConfig.ContextMenu = ['Generic','Anchor','Flash','Select','Textarea','Checkbox','Radio','TextField','HiddenField','ImageButton','Button','BulletedList','NumberedList','Table','Form'] ;

// ONLY CHANGE BELOW HERE
FCKConfig.SkinPath = FCKConfig.BasePath + 'skins/silver/';

FCKConfig.ToolbarSets["Easy"] = [
        ['Bold','Italic','Underline','StrikeThrough','-'],
        ['OrderedList','UnorderedList','-'],
        ['FontSize'], ['TextColor','BGColor'],
        ['easyImage', 'easyLink', 'Unlink']
] ;

FCKConfig.ToolbarSets["Simple"] = [
        ['Source'],
        ['Cut','Copy','Paste','PasteWord'],
        ['Undo','Redo','-','Find','Replace','-','SelectAll'],
        ['FontName','FontSize'],
        '/',
        ['Bold','Italic','Underline','StrikeThrough'],
        ['TextColor','BGColor'],
        ['OrderedList','UnorderedList','-','Outdent','Indent'],
        ['JustifyLeft','JustifyCenter','JustifyRight','JustifyFull'],
        ['Link','Unlink'],
        ['Image','Table','Rule','Smiley']
] ;

FCKConfig.ToolbarSets["Webmail_body"] = [
        ['FontSize','-',
         'TextColor','BGColor','Undo','Redo','Find','Replace','Bold','Italic','Underline','StrikeThrough',
         'OrderedList','UnorderedList','Outdent','Indent','JustifyLeft','JustifyCenter','JustifyRight','Rule']
] ;

FCKConfig.EnterMode = 'br' ;			// p | div | br
FCKConfig.ShiftEnterMode = 'p' ;	// p | div | br


