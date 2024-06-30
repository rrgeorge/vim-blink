if exists("g:loaded_blink")
	finish
endif
let g:loaded_blink=1

let s:active_jobs=get(s:,"active_jobs",[])
let s:job_queue=get(s:,"job_queue",[])

function! blink#init()
    if exists("g:blink_path")
        let s:blink_path = expand(g:blink_path)
    else
        let s:blink_path = expand("~/.vim/pack/blink")
    endif
    call mkdir(s:blink_path."/opt","p")
endfunction

function! blink#new_window()
    redraw!
    redraw!
    let s:blink_window = get(s:, 'blink_window', -1)
    let buflist = tabpagebuflist()
    if s:blink_window < 0 || index(buflist,s:blink_window) < 0
	if bufexists('[vim-blink]')
		split [vim-blink]
	else
		new
		setlocal buftype=nofile bufhidden=hide noswapfile
		silent file [vim-blink]
		let s:blink_window = bufnr()
		call setbufline(s:blink_window,0,"vim-blink plugin manager")
	endif
	redraw
    endif
endfunction

function! blink#activate(url)
    let pluginname = substitute(a:url,"/","_",'')
    if (!isdirectory(s:blink_path."/opt/".pluginname))
        let job = blink#install(a:url,0)
        while job_status(job) == 'run'
            sleep 5m
        endwhile
    endif
    exe "packadd! ".pluginname
endfunction

function! blink#install(url,update=0)
    call blink#new_window()
    let pluginname = substitute(a:url,"/","_",'')
    if (isdirectory(s:blink_path."/opt/".pluginname) && a:update==0)
	call appendbufline(s:blink_window, '$', a:url." is already installed")
        return
    elseif a:update != 0
    	"echom "Checking" a:url "for updates..."
	call appendbufline(s:blink_window, '$', "Checking ".a:url." for updates...")
    endif
    while len(s:active_jobs) > 0
        sleep 10m
    	call filter(s:active_jobs,"job_status(v:val.job) == 'run'")
    endwhile
    let branch = blink#ghBranch(a:url)
    if branch is v:null
	return
    endif
    let commit = blink#ghLastCommit(a:url,branch)
    if commit is v:null
	return
    endif
    if filereadable(expand(s:blink_path."/opt/".pluginname."/.blinkplugin.version"))
        let current = readfile(expand(s:blink_path."/opt/".pluginname."/.blinkplugin.version"))
        if current[0] == commit
            "echom "The latest version of" a:url "is already installed"
	    call appendbufline(s:blink_window, '$', "The latest version of ".a:url." is already installed")
            return
        endif
    endif
    let url = "https://github.com/".a:url."/archive/".branch.".tar.gz"
    call appendbufline(s:blink_window, '$', "Downloading ".a:url."/archive/".branch.".tar.gz...")
    let cmd = "curl -fLo ".s:blink_path."/".pluginname."-".branch."-".commit.".tgz ".url
    let active_job = { 'plugin': a:url, 'branch': branch, 'commit': commit, 'name': pluginname }
    let job = job_start(cmd, {'err_cb': 's:curlProgress','exit_cb': 's:Done', 'err_mode': 'raw'})
    let active_job.job = job
    let active_job.channel = job_getchannel(job)
    call add(s:active_jobs,active_job)
    return job
endfunction

function! blink#update()
    let plugins = glob(s:blink_path."/opt/*/.blinkplugin.repo",0,1)
    for plugin in plugins
        call blink#install(readfile(plugin)[0],1)
    endfor
endfunction

function! blink#ghBranch(url)
    let url = "https://github.com/".a:url."/refs?type=branch"
    let cmd = "curl -s -H 'accept: application/json' ".url
    let job = job_start(cmd)
    while job_status(job) == 'run'
    endwhile
    let resp = ch_readraw(job)
    try
        let resp = json_decode(resp)
        if has_key(resp,'error')
            echow "Error getting branch for" a:url ":" resp['error']
            return v:null
        endif
        let branch = resp['refs'][0]
        return branch
    catch
        echow "Error getting branch for" a:url ": unknown response"
        return v:null
    endtry
endfunction

function! blink#ghLastCommit(url, branch)
    let url = "https://github.com/".a:url."/latest-commit/".a:branch
    let cmd = "curl -s -H 'accept: application/json' ".url
    let job = job_start(cmd)
    while job_status(job) == 'run'
    endwhile
    let resp = ch_readraw(job)
    try
        let resp = json_decode(resp)
        if has_key(resp,'error')
            echow "Error getting latest commit hash for" a:url ":" resp['error']
            return v:null
        endif
        let commit = resp['oid'][:6]
        return commit
    catch
        echow "Error getting branch for" a:url ": unknown response"
        return v:null
    endtry
endfunction

function s:curlProgress(channel, msg)
    for j in s:active_jobs
        if j.channel == a:channel
            let active_job = j
            break
        endif
    endfor
    if !exists("active_job.message")
	let active_job.message = ''
    endif
    for i in range(0,strlen(a:msg))
        if a:msg[i:i] =~ '[\xd\x0]'
            if strlen(active_job.message) > 0
		"redraw!
                let pct = matchstr(active_job.message,'[0-9]\+')
                if pct > 0
                    let pct .= '%'
                    "echom 'Downloading ' . active_job.plugin . ': ' . pct
                    call setbufline(s:blink_window, '$', 'Downloading '.active_job.plugin.': '.pct)
                else
                    "echom 'Downloading ' . active_job.plugin . '...'
                    call setbufline(s:blink_window, '$', 'Downloading '.active_job.plugin.'...')
                endif
            endif
            let active_job.message = ''
        else
            let active_job.message .= a:msg[i:i]
        endif
    endfor
endfunction

function s:Done(job, status)
    for j in s:active_jobs
        if j.job == a:job
            let active_job = j
            break
        endif
    endfor
   unlet active_job.message
   sleep 5m
   if a:status != 0
	"redraw!
	echow 'Could not download' active_job.plugin 'Err:' a:status
	unlet active_job
	return
   endif
   "redraw!
   "echom 'Downloaded ' . active_job.plugin . '!'
   call setbufline(s:blink_window, '$', 'Downloaded '.active_job.plugin)
   call s:unpack(active_job)
endfunction

function s:unpack(job)
    let plugin = a:job.plugin
    let branch = a:job.branch
    let commit = a:job.commit
    let name = a:job.name
    "redraw!
    "echom "Extracting plugin: ".plugin
    call setbufline(s:blink_window, '$', 'Extracting: '.plugin)
    call mkdir(s:blink_path."/opt/".name,"p")
    let cmd = "tar xf ".s:blink_path."/".name."-".branch."-".commit.".tgz --strip-components=1 -C ".s:blink_path."/opt/".name
    let job = job_start(cmd, {'exit_cb': 's:Finish'})
    let a:job.job = job
endfunction

function s:Finish(job,status)
    "redraw!
    for j in s:active_jobs
        if j.job == a:job
            let active_job = j
            break
        endif
    endfor
    let plugin = active_job.plugin
    let branch = active_job.branch
    let commit = active_job.commit
    let name = active_job.name
    call writefile([commit], s:blink_path."/opt/".name."/.blinkplugin.version", 'b')
    call writefile([plugin], s:blink_path."/opt/".name."/.blinkplugin.repo", 'b')
    call delete(s:blink_path."/".name."-".branch."-".commit.".tgz")
    "echom "Installed plugin: ".plugin
    call setbufline(s:blink_window, '$', 'Installed '.plugin)
    call filter(s:active_jobs,"v:val != active_job")
    "sleep 1
    "redraw
endfunction

call blink#init()

command! -bang -nargs=+ BlinkInstall call blink#install(<args>,<bang>0)
command! -nargs=1 Blink call blink#activate(<args>)
command! -nargs=0 BlinkUpdate call blink#update()

