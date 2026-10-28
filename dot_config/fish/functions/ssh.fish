function ssh --wraps='ghostty +ssh --' --description 'alias ssh=ghostty +ssh --'
    ghostty +ssh -- $argv
end
