return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- nvim-treesitter v1.x: highlight and indent are enabled by default.
    -- Install parsers with :TSInstall <lang> or :TSInstall all
    config = function()
        -- No setup() needed in v1.x; highlight/indent are on by default.
        -- Register any language aliases if needed:
        -- vim.treesitter.language.register("ruby", "eruby")
    end,
}
