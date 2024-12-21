return {{
    'phaazon/hop.nvim',
    branch = 'v2',
    keys = {{
        'f',
        function()
            require('hop').hint_char1()
        end,
        mode = {'n', 'x'},
        desc = '[f]ind to the character you searched.'
    }, {
        'F',
        function()
            require('hop').hint_words()
        end,
        mode = {'n', 'x'},
        desc = '[F]ind any word\'s begining.'
    }},
    config = true
}}
