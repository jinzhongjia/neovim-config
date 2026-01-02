-- yamlls: YAML LSP
return {
    settings = {
        yaml = {
            validate = true,
            hover = true,
            completion = true,
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/github-action.json"] = "/.github/actions/**/action.{yml,yaml}",
                ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.{yml,yaml}",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "compose*.{yml,yaml}",
            },
        },
    },
}
