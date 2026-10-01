-- Focus Admin By Request and wait for the user to start an admin session.
-- The user presses Enter themselves; Ghostty's native focus command returns
-- to the original terminal pane afterward.
use scripting additions

on sessionIsActive()
    tell application "System Events"
        if not (exists application process "Admin By Request") then return false
        tell application process "Admin By Request"
            if not (exists window "Administrator Access") then return false
            return exists button "Finish" of window "Administrator Access"
        end tell
    end tell
end sessionIsActive

on focusRequestWindow()
    tell application "System Events"
        if not (exists application process "Admin By Request") then return false
        tell application process "Admin By Request"
            repeat with windowTitle in {"Administrator Access", "Request Administrator Access"}
                if exists window (contents of windowTitle) then
                    set visible to true
                    set frontmost to true
                    perform action "AXRaise" of window (contents of windowTitle)
                    return true
                end if
            end repeat
        end tell
    end tell
    return false
end focusRequestWindow

on restoreFocus(previousTerminalID)
    if previousTerminalID is missing value then return
    -- Let the timer window finish appearing, then hide it without clicking
    -- Finish or ending the admin session.
    delay 0.3
    try
        tell application "System Events"
            if exists application process "Admin By Request" then
                set visible of application process "Admin By Request" to false
            end if
        end tell
    end try

    repeat 5 times
        tell application "Ghostty"
            set matchingTerminals to every terminal whose id is previousTerminalID
            if (count of matchingTerminals) is 0 then
                error "The original Ghostty terminal was closed. sudo was cancelled." number 1
            end if
            activate
            focus (item 1 of matchingTerminals)
        end tell

        delay 0.2
        tell application "Ghostty"
            if frontmost then
                if (id of focused terminal of selected tab of front window) is previousTerminalID then return
            end if
        end tell
    end repeat

    error "Ghostty did not regain focus. sudo was cancelled; check Ghostty automation permission." number 1
end restoreFocus

on run
    set previousTerminalID to missing value

    try
        -- Capture the actual terminal pane rather than the frontmost process.
        tell application "Ghostty"
            set previousTerminalID to id of focused terminal of selected tab of front window
        end tell

        -- Restore focus even when a session is already active. This also makes
        -- retries work while the previous session's timer window is still open.
        if my sessionIsActive() then
            my restoreFocus(previousTerminalID)
            return
        end if

        do shell script "/usr/bin/open -b com.fasttracksoftware.adminbyrequest"

        set launchDeadline to (current date) + 15
        repeat
            if my sessionIsActive() then exit repeat
            if my focusRequestWindow() then exit repeat
            if (current date) is greater than launchDeadline then
                error "Admin By Request did not open its request window. sudo was cancelled." number 1
            end if
            delay 0.2
        end repeat

        set approvalDeadline to (current date) + 120
        repeat until my sessionIsActive()
            if (current date) is greater than approvalDeadline then
                error "No active Admin By Request session after two minutes. sudo was cancelled." number 1
            end if
            delay 0.2
        end repeat

        my restoreFocus(previousTerminalID)
    on error errorMessage number errorNumber
        try
            my restoreFocus(previousTerminalID)
        end try
        error errorMessage number errorNumber
    end try
end run
