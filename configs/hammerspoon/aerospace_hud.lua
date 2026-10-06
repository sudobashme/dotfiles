local M = {}
local path = os.getenv('HOME') .. '/.config/aerospace/aerospace.toml'
local descriptions = {
    ['fullscreen'] = 'Fill screen / restore',
    ['layout floating tiling'] = 'Float / tile window',
    ['layout tiles horizontal vertical'] = 'Tile / change orientation',
    ['layout accordion horizontal vertical'] = 'Accordion layout',
    ['balance-sizes'] = 'Balance window sizes',
    ['enable toggle'] = 'Pause / resume tiling',
    ['reload-config'] = 'Reload AeroSpace config',
    ['exec-and-forget open -a kitty'] = 'Open kitty',
    ['workspace-back-and-forth'] = 'Previous workspace',
    ['move-workspace-to-monitor --wrap-around next'] = 'Workspace to next monitor',
    ['mode service'] = 'Enter service mode',
    ['resize smart -50'] = 'Shrink window',
    ['resize smart +50'] = 'Enlarge window',
}
local names = {alt='⌥', shift='⇧', ctrl='⌃', cmd='⌘', space='Space',
    enter='Return', tab='Tab', minus='−', equal='=', slash='/', comma=',', semicolon=';'}
local function keyLabel(key)
    local parts = {}
    for part in key:gmatch('[^-]+') do parts[#parts+1] = names[part] or part:upper() end
    return table.concat(parts, ' ')
end

-- Read the single-line string bindings used by this config, each time HUD opens.
-- This is deliberately not a general TOML parser. Fail visibly on new syntax.
function M.readBindings()
    local file, err = io.open(path, 'r')
    if not file then return nil, err end
    local groups = {{title='FOCUS & MOVE'}, {title='WORKSPACES'}, {title='LAYOUT & CONTROLS'}}
    local active = false
    for line in file:lines() do
        local section = line:match('^%s*%[([^%]]+)%]%s*$')
        if section then active = section == 'mode.main.binding' end
        if active and not line:match('^%s*#') then
            local key, command = line:match("^%s*([%w%-]+)%s*=%s*'([^']*)'%s*")
            if not key then key, command = line:match('^%s*([%w%-]+)%s*=%s*"([^"]*)"%s*') end
            if key then
                local group = command:match('^focus ') or command:match('^move ') or command:match('^resize ')
                group = group and groups[1] or (command:find('workspace',1,true) and groups[2] or groups[3])
                local label = descriptions[command] or command:gsub('^focus ', 'Focus '):gsub('^move ', 'Move window ')
                    :gsub('^workspace ', 'Switch to '):gsub('^move%-node%-to%-workspace ', 'Send window to ')
                group[#group+1] = {key=keyLabel(key), label=label}
            elseif line:match('^%s*[%w%-]+%s*=') then
                file:close()
                return nil, 'Unsupported main binding syntax: ' .. line
            end
        end
    end
    file:close()
    -- Collapse the numbered rows only when all nine bindings match exactly.
    for _, rule in ipairs({{prefix='⌥ ', label='Switch to ', summary='Switch workspace'},
        {prefix='⌥ ⇧ ', label='Send window to ', summary='Send window to workspace'}}) do
        local found = {}
        for _, row in ipairs(groups[2]) do
            for number=1,9 do
                if row.key == rule.prefix .. number and row.label == rule.label .. number then found[number]=true end
            end
        end
        local complete = true
        for number=1,9 do if not found[number] then complete=false end end
        if complete then
            local compact, inserted = {title=groups[2].title}, false
            for _, row in ipairs(groups[2]) do
                local number = row.label:match('^' .. rule.label .. '([1-9])$')
                if number and row.key == rule.prefix .. number then
                    if not inserted then compact[#compact+1]={key=rule.prefix .. '1–9',label=rule.summary}; inserted=true end
                else compact[#compact+1]=row end
            end
            groups[2]=compact
        end
    end
    return groups
end

function M.hide()
    if M.panel then M.panel:delete(); M.panel = nil end
end

function M.show()
    M.hide()
    local groups, err = M.readBindings()
    if not groups then hs.alert.show('AeroSpace HUD: ' .. err); return end
    local focused = hs.window.focusedWindow()
    local screen = (focused and focused:screen()) or hs.mouse.getCurrentScreen()
    local frame = screen:frame()
    local width = math.min(1160, frame.w - 32)
    local rows = math.max(#groups[1], #groups[2], #groups[3])
    local height = 156 + rows * 25
    local scale = math.min(1, (frame.h - 32) / height, width / 1000)
    height = height * scale
    local canvas = hs.canvas.new({x=frame.x+(frame.w-width)/2, y=frame.y+12, w=width, h=height})
    M.panel = canvas
    canvas:level(hs.canvas.windowLevels.overlay):behaviorAsLabels({'canJoinAllSpaces','fullScreenAuxiliary'})
    canvas:clickActivating(false)
    canvas:appendElements({type='rectangle', action='strokeAndFill',
        roundedRectRadii={xRadius=16,yRadius=16}, fillColor={hex='#161C29',alpha=0.97},
        strokeColor={hex='#40506B'}, strokeWidth=1, frame={x=0,y=0,w=width,h=height}})
    local function text(value,x,y,w,size,color)
        canvas:appendElements({type='text', text=value, textFont='Menlo', textSize=size*scale,
            textColor={hex=color or '#E9EDF5'}, frame={x=x,y=y*scale,w=w,h=25*scale}})
    end
    text('AEROSPACE  /  KEYBOARD REFERENCE',24,20,width-48,19)
    text('⌥ Space  show / hide     •     ⌥ Option   ⇧ Shift',24,52,width-48,12,'#A8B8CE')
    local column = (width-48)/3
    for index, group in ipairs(groups) do
        local x = 24+(index-1)*column
        text(group.title,x,94,column-16,13,'#80CAFF')
        for row, binding in ipairs(group) do
            local y = 124+(row-1)*25
            text(binding.key,x,y,106*scale,13,'#80CAFF')
            text(binding.label,x+106*scale,y,column-112*scale,12)
        end
    end
    canvas:show(0.12)
end

function M.toggle()
    if M.panel then M.hide() else M.show() end
end
return M
