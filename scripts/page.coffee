
p = console.log.bind(console)

createJoin = (n, callback) ->
    kwargs = {}
    (arg) ->
        _.extend(kwargs, arg)
        if --n <= 0
            callback.call({}, kwargs)

URL = 
    BASE: 'http://spurt.elasticbeanstalk.com'
    CREATE: 'http://spurt.elasticbeanstalk.com/link-posts/create'
    EDIT: 'http://spurt.elasticbeanstalk.com/link-posts/edit'
    PUBLISH: 'http://spurt.elasticbeanstalk.com/link-posts/publish'

BUTTON_THROTTLE = 3000

background = chrome.extension.getBackgroundPage()

global = 
    publish: false
    requests: 0
global.uuid = 1

setStatus = (status) ->
    $('.status').text(status)

create = ->
    $.post(URL.CREATE,
        {
            uuid: global.uuid,
            url: global.url
        },
        (res) ->
            global.id = JSON.parse(res).id
            joinSave())

save = ->
    console.log('save')
    console.log('publish', global.publish)
    
    global.requests += 1
    
    if global.publish
        url = URL.PUBLISH
    else
        url = URL.EDIT
        
    $.post(url,
        {
            uuid: global.uuid,
            id: global.id,
            title: $('[name=title]').text(),
            description: $('[name=description]').text()
        },
        (args...) ->
            console.log(args)
            
            global.requests -= 1
            if global.publish
                onPublish()
            else if global.requests <= 0
                setStatus('Post Saved!'))

onPublish = ->
    setStatus('All Done!')
    $('div:not(.status-container)').slideUp()
    setTimeout(window.close.bind(window), 2500)

joinSave = createJoin(2, save)

chrome.tabs.getSelected((tab) ->
    global.url = tab.url
    create())

$(document).ready(->
    throttled = _.throttle((->
            if global.id
                save()
            else if not clicked
                clicked = true
                joinSave()),
        BUTTON_THROTTLE)
    
    clicked = false
    $('#save').click(->
        if not global.publish
            setStatus('Saving...')
        throttled())
    $('#publish').click(->
        setStatus('Posting...')
        global.publish = true
        throttled()))
