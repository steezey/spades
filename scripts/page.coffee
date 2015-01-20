
URL = 
    BASE: 'http://spurt.elasticbeanstalk.com'
    CREATE: 'http://spurt.elasticbeanstalk.com/link-posts/create'
    EDIT: 'http://spurt.elasticbeanstalk.com/link-posts/edit'
    PUBLISH: 'http://spurt.elasticbeanstalk.com/link-posts/publish'

createJoin = (n, callback) ->
    kwargs = {}
    (arg) ->
        _.extend(kwargs, arg)
        if --n <= 0
            callback.call({}, kwargs)

background = chrome.extension.getBackgroundPage()

global = {}
global.uuid = 1

chrome.tabs.getSelected((tab) ->
    global.url = tab.url
    
    background.run(->
        $.post(URL.CREATE,
            {
                uuid: uuid,
                url: url
            },
            (args...) ->
                console.log(args))))
