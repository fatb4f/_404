package dotfiles

#Family: "bin" | "broot" | "nvim" | "uv"

#Kind: "file" | "symlink"

#Role: "config" | "script" | "lockfile"

#Path: =~"^\\.config/(bin|broot|nvim|uv)(/|$)"

#TrackedSpec: close({
	path:   #Path
	kind:   #Kind
	family: #Family
	role:   #Role
})

#ObservedSpec: close({
	path:   #Path
	kind:   #Kind
	family: #Family
})

policy: {
	managedRoots: [
		".config/bin",
		".config/broot",
		".config/nvim",
		".config/uv",
	]

	allowedTracked: close({
		".config/bin/.gitignore": {
			path:   ".config/bin/.gitignore"
			kind:   "file"
			family: "bin"
			role:   "config"
		}

		".config/bin/config.json.tmpl": {
			path:   ".config/bin/config.json.tmpl"
			kind:   "file"
			family: "bin"
			role:   "config"
		}

		".config/broot/conf.hjson": {
			path:   ".config/broot/conf.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/preview_transformers.hjson": {
			path:   ".config/broot/preview_transformers.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/catppuccin-macchiato.hjson": {
			path:   ".config/broot/skins/catppuccin-macchiato.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/catppuccin-mocha.hjson": {
			path:   ".config/broot/skins/catppuccin-mocha.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/dark-blue.hjson": {
			path:   ".config/broot/skins/dark-blue.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/dark-gruvbox.hjson": {
			path:   ".config/broot/skins/dark-gruvbox.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/dark-orange.hjson": {
			path:   ".config/broot/skins/dark-orange.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/native-16.hjson": {
			path:   ".config/broot/skins/native-16.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/solarized-dark.hjson": {
			path:   ".config/broot/skins/solarized-dark.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/solarized-light.hjson": {
			path:   ".config/broot/skins/solarized-light.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/tokyo-night.hjson": {
			path:   ".config/broot/skins/tokyo-night.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/skins/white.hjson": {
			path:   ".config/broot/skins/white.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/special_paths.hjson": {
			path:   ".config/broot/special_paths.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/broot/verbs.hjson": {
			path:   ".config/broot/verbs.hjson"
			kind:   "file"
			family: "broot"
			role:   "config"
		}

		".config/nvim/.gitignore": {
			path:   ".config/nvim/.gitignore"
			kind:   "file"
			family: "nvim"
			role:   "config"
		}

		".config/nvim/.neoconf.json": {
			path:   ".config/nvim/.neoconf.json"
			kind:   "file"
			family: "nvim"
			role:   "config"
		}

		".config/nvim/LICENSE": {
			path:   ".config/nvim/LICENSE"
			kind:   "file"
			family: "nvim"
			role:   "config"
		}

		".config/nvim/README.md": {
			path:   ".config/nvim/README.md"
			kind:   "file"
			family: "nvim"
			role:   "config"
		}

		".config/nvim/colors/tinted.vim": {
			path:   ".config/nvim/colors/tinted.vim"
			kind:   "file"
			family: "nvim"
			role:   "config"
		}

		".config/nvim/init.lua": {
			path:   ".config/nvim/init.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lazy-lock.json": {
			path:   ".config/nvim/lazy-lock.json"
			kind:   "file"
			family: "nvim"
			role:   "lockfile"
		}

		".config/nvim/lazyvim.json": {
			path:   ".config/nvim/lazyvim.json"
			kind:   "file"
			family: "nvim"
			role:   "config"
		}

		".config/nvim/lua/config/autocmds.lua": {
			path:   ".config/nvim/lua/config/autocmds.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/config/clipboard.lua": {
			path:   ".config/nvim/lua/config/clipboard.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/config/keymaps.lua": {
			path:   ".config/nvim/lua/config/keymaps.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/config/kitty.lua": {
			path:   ".config/nvim/lua/config/kitty.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/config/lazy.lua": {
			path:   ".config/nvim/lua/config/lazy.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/config/options.lua": {
			path:   ".config/nvim/lua/config/options.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/broot.lua": {
			path:   ".config/nvim/lua/plugins/broot.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/codecompanion.lua": {
			path:   ".config/nvim/lua/plugins/codecompanion.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/core.lua": {
			path:   ".config/nvim/lua/plugins/core.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/example.lua": {
			path:   ".config/nvim/lua/plugins/example.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/kitty-scrollback.lua": {
			path:   ".config/nvim/lua/plugins/kitty-scrollback.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/noice.lua": {
			path:   ".config/nvim/lua/plugins/noice.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/oil.lua": {
			path:   ".config/nvim/lua/plugins/oil.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/render-markdown.lua": {
			path:   ".config/nvim/lua/plugins/render-markdown.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/shell-format.lua": {
			path:   ".config/nvim/lua/plugins/shell-format.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/smart-splits.lua": {
			path:   ".config/nvim/lua/plugins/smart-splits.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/snacks.lua": {
			path:   ".config/nvim/lua/plugins/snacks.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/tinted-nvim.lua": {
			path:   ".config/nvim/lua/plugins/tinted-nvim.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/lua/plugins/treesitter.lua": {
			path:   ".config/nvim/lua/plugins/treesitter.lua"
			kind:   "file"
			family: "nvim"
			role:   "script"
		}

		".config/nvim/stylua.toml": {
			path:   ".config/nvim/stylua.toml"
			kind:   "file"
			family: "nvim"
			role:   "config"
		}

		".config/uv/.gitignore": {
			path:   ".config/uv/.gitignore"
			kind:   "file"
			family: "uv"
			role:   "config"
		}
	})

	allowedObserved: close({
		for k, v in allowedTracked {
			"\(k)": {
				path:   v.path
				kind:   v.kind
				family: v.family
			}
		}
	})
}

#Audit: {
	schema: "dotfiles.audit.v1"
	mode:   "allowlist"

	observed: {
		live_files:     policy.allowedObserved
		yadm_tracked:   policy.allowedObserved
		identity_hits:   close({})
		syntax_failures: close({})
	}
}
